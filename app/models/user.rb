class User < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: %i(slugged finders)

  devise :database_authenticatable, :rememberable, :trackable, :validatable,
    :registerable, :omniauthable, :recoverable

  mount_uploader :avatar, ImageUploader

  has_many :owner_calendars, as: :owner, class_name: Calendar.name, dependent: :destroy
  has_many :user_organizations, dependent: :destroy
  has_many :organizations, through: :user_organizations
  has_many :user_calendars, dependent: :destroy
  has_many :calendars, through: :user_calendars
  has_many :events
  has_many :attendees, dependent: :destroy
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

  scope :search, ->q{where "email LIKE ?", "%#{sanitize_sql_like q}%"}
  scope :search_name_or_email, (lambda do |q|
    where "name LIKE ? OR email LIKE ?", "%#{sanitize_sql_like q}%", "%#{sanitize_sql_like q}%"
  end)
  scope :order_by_email, ->{order email: :asc}

  accepts_nested_attributes_for :setting

  ATTR_PARAMS = [:name, :email, :chatwork_id, :password, :password_confirmation,
    setting_attributes: [:id, :timezone_name, :default_view, :country]].freeze

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
    def from_omniauth auth
      user = find_or_initialize auth

      if user.new_record?
        user.password = Devise.friendly_token[0, 20]
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
    owner_calendars.new name: name, is_default: true, owner_type: User.name,
      owner_id: self.id, creator: self, color: Color.all.sample, address: email
  end
end
