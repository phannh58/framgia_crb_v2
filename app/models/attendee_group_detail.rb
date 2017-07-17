class AttendeeGroupDetail < ApplicationRecord
  belongs_to :attendee
  belongs_to :group_attendee
end
