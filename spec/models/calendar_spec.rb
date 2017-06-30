require "rails_helper"

RSpec.describe Calendar, type: :model do
  it{should belong_to :color}
  it{should belong_to(:creator).class_name(User.name)
    .with_foreign_key :creator_id}
  it{should belong_to :owner}
  it{should have_many(:events).dependent :destroy}
  it{should have_many(:user_calendars).dependent :destroy}
  it{should have_many :users}
  it{should have_many(:sub_calendars).class_name(Calendar.name)
    .with_foreign_key :parent_id}
  it{should accept_nested_attributes_for(:user_calendars).allow_destroy true}
  it{should delegate_method(:name).to(:owner).with_prefix(true)
    .with_arguments allow_nil: true}
  it{should validate_presence_of :address}
  it{should validate_presence_of :owner}

  it "should have a valid fabricator" do
    user = Fabricate :user
    expect(Fabricate :calendar, owner: user).to be_valid
  end

  describe "#get_color" do
    let(:user) {Fabricate :user}
    let(:calendar) {Fabricate :calendar, owner: user}
    let(:calendar2) {Fabricate :calendar, owner: user}
    let(:permission) {Fabricate :permission}
    let(:color) {Fabricate :color}

    it "should return user_calendar color when it is present" do
      user_calender = Fabricate :user_calendar, user: user, calendar: calendar,
        permission: permission, color_id: color.id
      expect(calendar.get_color user.id).to eq user_calender.color_id
    end

    it "should return self color when it is not present" do
      expect(calendar2.get_color user.id).to eq 10
    end
  end

  describe "#parent?" do
    let(:user) {Fabricate :user}
    let(:calendar) {Fabricate :calendar, owner: user}
    let(:calendar2) {Fabricate :calendar, owner: user, parent_id: calendar.id}

    it "should return false when it has parent" do
      expect(calendar2.parent?).to be_falsy
    end

    it "should return true when it has no parent" do
      expect(calendar.parent?).to be_truthy
    end
  end

  describe "#bulding_name" do
    let(:user) {Fabricate :user}
    let(:calendar) {Fabricate :calendar, owner: user}
    let(:organization) {Fabricate :organization, creator_id: user.id}
    let(:workspace) {Fabricate :workspace, organization: organization}
    let(:calendar2) {Fabricate :calendar, owner: workspace}

    it "should return workspace name when owner_type is workspace" do
      expect(calendar2.bulding_name).to eq workspace.name
    end

    it "should return my calender when owner_type is user" do
      expect(calendar.bulding_name).to eq "My Calendars"
    end
  end

  describe "#make_user_calendar" do
    let(:user) {Fabricate :user}
    let(:user2) {Fabricate :user}
    let(:calendar) {Fabricate :calendar, owner: user}

    it "should create user_calender before create" do
      calendar = Calendar.new name: "meeting", owner: user2
      expect(calendar).to receive :make_user_calendar
      calendar.save
    end
  end

  describe "#make_address_uniq" do
    let(:user) {Fabricate :user}

    it "should call after initialize method" do
      calendar = Calendar.allocate
      expect(calendar).to receive :make_address_uniq
      calendar.send :initialize
    end

    it "should change address when the method is called" do
      calendar = Fabricate :calendar, owner: user, address: "ha noi"
      calendar.send :make_address_uniq
      expect(calendar.address).not_to be_nil
      expect(calendar.address).not_to eq "ha noi"
    end
  end
end
