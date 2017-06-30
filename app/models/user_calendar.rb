class UserCalendar < ApplicationRecord
  belongs_to :user
  belongs_to :calendar
  belongs_to :permission
  belongs_to :color

  validates :permission, :user, :calendar, presence: true

  delegate :email, :name, to: :user, prefix: true, allow_nil: true

  ATTR_PARAMS = %i(user_id permission_id color_id is_checked).freeze
end
