class UserOrganization < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  after_save :send_invitation, if: :waiting?

  delegate :name, :creator_id, to: :organization, prefix: true

  enum status: %i(waiting accepted)

  ATTRIBUTE_PARAMS = %i(organization_id user_id status).freeze

  validates :user, :organization, :status, presence: true

  private

  def send_invitation
    UserMailer.invite_to_join_organization(user_id, organization_id).deliver
  end

  handle_asynchronously :send_invitation, run_at: proc{1.minute.from_now}
end
