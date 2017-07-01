require "rails_helper"
require "ffaker"

RSpec.describe User, type: :model do
  subject {FactoryGirl.create :user}

  describe "associations" do
    it "has many calendars, many user_organizations, many organizations,
      many user_calendars, many shared_calendars, many events, many attendees,
      many invited_events, many user_teams, many teams, one setting" do

      expect(subject).to have_many(:calendars).dependent :destroy
      expect(subject).to have_many(:user_organizations).dependent :destroy
      expect(subject).to have_many(:organizations).through("user_organizations")
      expect(subject).to have_many(:user_calendars).dependent :destroy
      expect(subject).to have_many(:shared_calendars).through("user_calendars")
      expect(subject).to have_many(:events)
      expect(subject).to have_many(:attendees).dependent :destroy
      expect(subject).to have_many(:invited_events).through("attendees")
      expect(subject).to have_many(:user_teams).dependent :destroy
      expect(subject).to have_many(:teams).through("user_teams")
      expect(subject).to have_one(:setting).dependent :destroy
    end
  end

  describe "delegate" do
    it{should delegate_method(:timezone).to(:setting)
      .with_prefix(true).with_arguments(allow_nil: true)}
  end

  describe "Validations" do
    context "nane" do
      it "name should present, should be unique,
      length should be maximum 39 " do
        expect validate_presence_of subject.name
        expect validate_uniqueness_of(subject.name).case_insensitive
        expect validate_length_of(subject.name).is_at_most(39)
      end
    end

    context "email" do
      it "length should be maximum 39" do
        expect validate_length_of(subject.email).is_at_most(255)
      end
    end
  end

  describe "nested attribute" do
    it "should accept_nested_attributes_for setting" do
      expect accept_nested_attributes_for subject.setting
    end
  end

  context "scopes" do
    let!(:first_user) {FactoryGirl.create(:user, email: "test@gmail.com")}
    let!(:second_user) {FactoryGirl.create(:user, email: "testy@gmail.com")}
    let!(:third_user) {FactoryGirl.create(:user,
      name: "rails", email: "railstutorial@gmail.com")}

    let!(:org) {FactoryGirl.create :organization}
    let!(:organization_user) {FactoryGirl.create :user_organization,
      user_id: first_user.id, organization_id: org.id}

    it "should return users matched with the keyword to their email" do
      expect(User.search("test")).to eq([first_user, second_user])
      expect(User.search("aaa")).not_to eq([first_user, second_user])
    end

    it "should return users matched with the keyword to
      their name or email" do
      expect(User.search_name_or_email("rails")).to eq([third_user])
      expect(User.search_name_or_email("rails_tutorial"))
        .not_to eq([third_user])
    end

    it "should return users order by email in ascending" do
      expect(User.order_by_email).to eq([third_user, first_user, second_user])
      expect(User.order_by_email).not_to eq([second_user, first_user, third_user])
    end
  end

  describe "instance methods" do
    let!(:first_user) {FactoryGirl.create(:user, email: "ttt@gmail.com")}
    let!(:first_calendar) {FactoryGirl.create(:calendar,
      creator_id: first_user.id, name: "test", address: "test and test",
      workspace_id: 1, owner_id: first_user.id, owner_type: User.name,
      parent_id: 1, is_default: true)}
    let!(:second_user) {FactoryGirl.create(:user, email: "tt@gmail.com")}

    context "#has_permission?(calendar)" do
      it "returns user's calendar" do
        expect(User.first.has_permission?(first_calendar)).to eq(UserCalendar
          .find_by(user_id: first_user.id, calendar_id: first_calendar.id))
        expect(User.first.has_permission?(first_calendar)).not_to eq(UserCalendar
          .find_by(user_id: second_user.id, calendar_id: first_calendar.id))
      end
    end

    context "#default_calendar" do
      it "returns default calendar" do
        expect(first_user.default_calendar).to eq(Calendar
          .find_by(is_default: true))
        expect(second_user.default_calendar).not_to eq(Calendar
          .find_by(is_default: true))
      end
    end

    context "#is_user?(user)" do
      it "returns boolean indicating whether a record is of type User" do
        expect(first_user.is_user?(first_user)).to eq true
        expect(first_user.is_user?(first_calendar)).not_to eq true
      end
    end
  end
end
