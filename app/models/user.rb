class User < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:slugged, :finders]

  devise :database_authenticatable, :rememberable, :trackable, :validatable,
    :registerable, :omniauthable

  mount_uploader :avatar, ImageUploader

  has_many :calendars, as: :owner, dependent: :destroy
  has_many :user_organizations, dependent: :destroy
  has_many :organizations, through: :user_organizations
  has_many :user_calendars, dependent: :destroy
  has_many :shared_calendars, through: :user_calendars, source: :calendar
  has_many :events
  has_many :attendees, dependent: :destroy
  has_many :invited_events, through: :attendees, source: :event
  has_many :user_teams, dependent: :destroy
  has_many :teams, through: :user_teams
  has_one :setting, as: :owner, dependent: :destroy

  delegate :timezone, :timezone_name, :default_view,
    to: :setting, prefix: true, allow_nil: true

  validates :name, presence: true,
    length: {maximum: 39}, uniqueness: {case_sensitive: false}
  validates :email, length: {maximum: 255}
  validates_with NameValidator

  before_create :build_calendar
  before_create :generate_authentication_token!

  scope :search, ->q{where "email LIKE ?", "%#{q}%"}
  scope :search_name_or_email, ->q{where "name LIKE ? OR email LIKE ?", "%#{q}%", "%#{q}%"}
  scope :order_by_email, ->{order email: :asc}
  scope :can_invite_to_organization, (lambda do |organization_id|
    where NOT_YET_INVITE, organization_id
  end)
  scope :accepted_invite, (lambda do |q|
    joins(:user_organizations)
    .where("user_organizations.status = 1 AND user_organizations.organization_id = ?", "#{q}")
  end)
  accepts_nested_attributes_for :setting

  ATTR_PARAMS = [:name, :email, :chatwork_id, :password, :password_confirmation,
    setting_attributes: [:id, :timezone_name, :default_view, :country]].freeze

  NOT_YET_INVITE = "id NOT IN (SELECT DISTINCT user_organizations.user_id
    FROM user_organizations WHERE user_organizations.organization_id = ?)"

  def my_calendars
    Calendar.of_user self
  end

  def shared_calendars
    Calendar.shared_with_user self
  end

  def manage_calendars
    Calendar.managed_by_user self
  end

  Permission.permission_types.each_key do |permission_type|
    define_method("can_#{permission_type}?") do |calendar|
      user_calendar = user_calendars.find_by calendar: calendar
      return false unless user_calendar

      return user_calendar.permission.send("#{permission_type}?")
    end
  end

  def has_permission? calendar
    user_calendars.find_by calendar: calendar
  end

  def default_calendar
    calendars.find_by is_default: true
  end

  def is_user? user
    self == user
  end

  class << self
    def existed_email? email
      User.pluck(:email).include? email
    end

    def from_omniauth auth
      user = find_or_initialize auth

      if user.new_record?
        user.build_setting timezone_name: ActiveSupport::TimeZone.all.sample.name
      end
      user.save
      user
    end

    def find_or_initialize auth
      require "extensions/string_utils"
      find_or_initialize_by(email: auth.info.email).tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.display_name = auth.info.name
        user.name ||= make_name(auth)
      end
    end

    def make_name auth
      name = StringUtils.new auth.info.name
      name.to_slug
    end
  end

  def generate_authentication_token!
    auth_token = Devise.friendly_token while
      self.class.exists? auth_token: auth_token
  end

  def make_cable_token!
    update_attributes cable_token: Devise.friendly_token
  end

  def remove_cable_token!
    update_attributes cable_token: nil
  end

  private

  def build_calendar
    calendars.new name: name, is_default: true,
      creator: self, color: Color.all.sample, address: email
  end
end
