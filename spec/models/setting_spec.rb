require "rails_helper"

RSpec.describe Setting, type: :model do
  let!(:user) {FactoryGirl.create :user}
  subject {FactoryGirl.create :setting, owner: user}

  describe "validations" do
    it "timezone_name should be present" do
      expect validate_presence_of subject.timezone_name
    end

    it "should have a valid fabricator" do
      user = Fabricate :user
      expect(Fabricate :setting, owner_id: user.id,
        owner_type: "User").to be_valid
    end
  end

  describe "associations" do
    it "belong to user" do
      expect(subject).to belong_to(:owner)
    end
  end
end
