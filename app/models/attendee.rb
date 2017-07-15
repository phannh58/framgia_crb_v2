class Attendee < ApplicationRecord
  belongs_to :user

  delegate :name, :email, to: :user, prefix: :user, allow_nil: :true
  delegate :chatwork_id, to: :user, allow_nil: :true

  before_save :assign_email, if: "user.present?"

  private

  def assign_email
    self.email = user_email
  end
end
