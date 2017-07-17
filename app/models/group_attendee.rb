class GroupAttendee < ApplicationRecord
  belongs_to :user
  has_many :attendee_group_details
  has_many :attendees, through: :attendee_group_details

  validates :name, presence: true
end
