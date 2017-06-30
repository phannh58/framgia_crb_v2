class UserOrganization < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  after_create :send_invitation_email

  delegate :name, :creator_id, to: :organization, prefix: true

  enum status: %i(waiting accept)

  ATTRIBUTE_PARAMS = [:organization_id].freeze

  validates :user, :organization, presence: true

  private

  def send_invitation_email
    UserMailer.invite_to_join_organization(user_id, organization_id).deliver
  end

  handle_asynchronously :send_invitation_email, run_at: proc{1.minutes.from_now}
end
