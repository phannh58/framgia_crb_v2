require "rails_helper"

RSpec.describe Permission, type: :model do
  it{should belong_to(:user).dependent :destroy}

  it "should have a valid fabricator" do
    user = Fabricate :user
    organization = Fabricate :organization, creator_id: user.id
    user_organization = Fabricate :user_organization, user: user,
      organization: organization
    expect(Fabricate :permission, user: user).to be_valid
  end
end
