class Calendar < ApplicationRecord
  belongs_to :color
  belongs_to :creator, class_name: User.name, foreign_key: :creator_id
  belongs_to :owner, polymorphic: true
  has_many :events, dependent: :destroy
  has_many :user_calendars, dependent: :destroy
  has_many :users, through: :user_calendars
  has_many :sub_calendars, class_name: Calendar.name, foreign_key: :parent_id

  ATTRIBUTES_PARAMS = [
    :name, :number_of_seats, :google_calendar_id, :description, :color_id,
    :parent_id, :status, :is_allow_overlap,
    user_calendars_attributes: %I[id user_id permission_id color_id _destroy]
  ].freeze

  accepts_nested_attributes_for :user_calendars, allow_destroy: true,
    reject_if: proc{|attributes| attributes["user_id"] == @owner_id}

  before_create :make_user_calendar
  after_initialize :make_address_uniq, if: "address.nil?"

  enum status: %i(no_public share_public public_hide_detail)

  delegate :name, to: :owner, prefix: true, allow_nil: true

  validates :address, presence: true, uniqueness: {case_sensitive: false}
  validates :owner, presence: true

  scope :of_user, (lambda do |user|
    select("calendars.*, uc.user_id, uc.calendar_id, p.permission_type, uc.is_checked, uc.color_id as uc_color_id")
      .joins("INNER JOIN user_calendars as uc ON calendars.id=uc.calendar_id AND uc.user_id=#{user.id}")
      .joins("INNER JOIN permissions as p ON p.id = uc.permission_id")
      .where(
        calendars: {
          owner_id: user.id,
          owner_type: User.name
        }
      )
  end)
  scope :shared_with_user, (lambda do |user|
    select("calendars.*, uc.user_id, uc.calendar_id, p.permission_type, uc.is_checked, uc.color_id as uc_color_id")
      .joins("INNER JOIN user_calendars as uc ON uc.calendar_id=calendars.id AND uc.user_id=#{user.id}")
      .joins("INNER JOIN permissions as p ON p.id = uc.permission_id")
      .where(
        "(owner_id <> ? AND owner_type = ?) OR owner_type <> ? ",
        user.id, User.name, User.name
      )
  end)
  scope :managed_by_user, (lambda do |user|
    select("calendars.*, uc.user_id, uc.calendar_id, p.permission_type, uc.is_checked, uc.color_id as uc_color_id")
      .joins("INNER JOIN user_calendars as uc ON uc.calendar_id = calendars.id")
      .joins("INNER JOIN permissions as p ON p.id = uc.permission_id")
      .where(
        "uc.user_id = ? AND p.permission_type IN (?)",
        user.id,
        [
          Permission.permission_types[:make_changes_and_manage_sharing],
          Permission.permission_types[:make_changes_to_events]
        ]
      )
  end)
  scope :of_org, (lambda do |org|
    if org
      select("calendars.*, uc.user_id, uc.calendar_id, p.permission_type, uc.is_checked, uc.color_id as uc_color_id")
        .joins("INNER JOIN user_calendars as uc ON uc.calendar_id = calendars.id")
        .joins("INNER JOIN permissions as p ON p.id = uc.permission_id")
        .where("(calendars.owner_type = ? AND calendars.owner_id = ?)
          OR (calendars.owner_type = ? AND calendars.owner_id IN (?))",
          Organization.name, org.id, Workspace.name, org.workspace_ids)
    else
      Calendar.none
    end
  end)

  def get_color user_id
    user_calendar = user_calendars.find_by user_id: user_id
    user_calendar.present? ? user_calendar.color_id : color_id
  end

  def parent?
    parent_id.nil?
  end

  def bulding_name
    return owner_name if Workspace.name == owner_type
    return "My Calendars" if User.name == owner_type
  end

  private

  def make_user_calendar
    user_calendars.new user_id: creator_id,
      permission: Permission.make_changes_and_manage_sharing.first,
      color_id: color_id
  end

  def make_address_uniq
    str_uniq = Calendar.generate_unique_secure_token.downcase!
    self.address = str_uniq + "@" + Settings.mail_server
  end
end
