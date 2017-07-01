require "rails_helper"

RSpec.describe Organization, type: :model do
  subject {FactoryGirl.create :organization}

  describe "associations" do
    it "has many user_organizations, many teams, many calendars, one setting" do
      expect(subject).to have_many(:user_organizations).dependent :destroy
      expect(subject).to have_many(:users).through("user_organizations")
      expect(subject).to have_many(:teams).dependent :destroy
      expect(subject).to have_many :calendars
      expect(subject).to have_one :setting
    end
  end

  describe "Validations" do
    it "name should present, should be unique, length should be maximum 39 and validate with name validator" do
      expect validate_presence_of subject.name
      expect validate_uniqueness_of(subject.name).case_insensitive
      expect validate_length_of(subject.name).is_at_most(39)
    end
  end

  it "should accept_nested_attributes_for setting and workspaces" do
    expect accept_nested_attributes_for subject.setting
    expect accept_nested_attributes_for subject.workspaces
  end

  context "scopes" do
    let!(:first_organization) {FactoryGirl.create(:organization)}
    let!(:last_organization) {FactoryGirl.create(:organization)}

    it "should return organizations in descending order by create at" do
      expect(Organization.order_by_creation_time).to eq([first_organization, last_organization])
    end

    it "should return organizations in descending order by updated at" do
      first_organization.update(updated_at: 2.days.ago)
      last_organization.update(updated_at: 1.days.ago)\

      expect(Organization.order_by_updated_time).to eq([first_organization, last_organization])
    end
  end
end
