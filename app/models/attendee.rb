class Attendee < ApplicationRecord
  belongs_to :user
  has_many :attendee_group_details
  has_many :group_attendees, through: :attendee_group_details

  delegate :name, :email, to: :user, prefix: :user, allow_nil: :true
  delegate :chatwork_id, to: :user, allow_nil: :true

  before_save :assign_email, if: "user.present?"

  private

  def assign_email
    self.email = user_email
  end
end
