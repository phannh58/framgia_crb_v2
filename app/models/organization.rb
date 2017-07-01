class Organization < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  mount_uploader :logo, ImageUploader

  before_create :make_user_organization

  belongs_to :creator, class_name: User.name, foreign_key: :creator_id
  has_many :user_organizations, dependent: :destroy
  has_many :users, through: :user_organizations
  has_many :teams, dependent: :destroy
  has_many :calendars, as: :owner
  has_many :workspaces
  has_one :setting, as: :owner

  validates :name, presence: true,
    length: {maximum: 39}, uniqueness: {case_sensitive: false}
  validates_with NameValidator

  delegate :name, to: :owner, prefix: :owner, allow_nil: true
  delegate :timezone, :timezone_name, :default_view,
    to: :setting, prefix: true, allow_nil: true

  accepts_nested_attributes_for :workspaces,
    reject_if: proc{|attributes| attributes["name"].blank?}
  accepts_nested_attributes_for :setting

  scope :order_by_creation_time, ->{order created_at: :desc}
  scope :order_by_updated_time, ->{order updated_at: :desc}

  ATTRIBUTE_PARAMS = [:name, :logo,
    workspaces_attributes: [:id, :name, :address],
    setting_attributes: [:id, :timezone_name, :default_view, :country]].freeze

  def accepted_users
    users.joins(:user_organizations)
         .where("user_organizations.status = ?", UserOrganization.statuses[:accepted])
  end

  private

  def make_user_organization
    user_organizations.new user_id: creator_id, status: :accepted
  end
end
