require "rails_helper"

RSpec.describe Event, type: :model do
  let!(:user) {FactoryGirl.create :user}
  let!(:calendar) {FactoryGirl.create :calendar, owner: user}
  subject {FactoryGirl.create :event, calendar_id: calendar.id}

  describe "associations" do
    it "has many attendees, many users, many repeat_ons,
      many days_of_weeks, many event_exceptions,
      many notification_events, many notifications,
      many event_teams, many teams" do
      expect(subject).to have_many(:attendees).dependent :destroy
      expect(subject).to have_many(:users).through("attendees")
      expect(subject).to have_many(:repeat_ons).dependent :destroy
      expect(subject).to have_many(:days_of_weeks).through("repeat_ons")
      expect(subject).to have_many(:event_exceptions)
        .class_name(Event.name).with_foreign_key("parent_id")
        .dependent(:destroy)
      expect(subject).to have_many(:notification_events)
        .dependent :destroy
      expect(subject).to have_many(:notifications)
        .through("notification_events")
      expect(subject).to have_many(:event_teams).dependent :destroy
      expect(subject).to have_many(:teams).through("event_teams")
    end

    it "belongs_to calendar, owner, event_parent" do
      expect(subject).to belong_to :calendar
      expect(subject).to belong_to(:owner).class_name(User.name)
        .with_foreign_key("user_id")
      expect(subject).to belong_to(:event_parent).class_name(Event.name)
        .with_foreign_key("parent_id")
    end
  end

  describe "Validations" do
    context "calendar" do
      it "calendar should be present" do
        expect validate_presence_of calendar
      end
    end

    context "start_date" do
      it "start_date should be present" do
        expect validate_presence_of subject.start_date
      end
    end

    context "finish_date" do
      it "finish_date should be present" do
        expect validate_presence_of subject.finish_date
      end
    end
  end

  describe "delegate" do
    it{should delegate_method(:name).to(:owner)
      .with_prefix(:owner).with_arguments(allow_nil: true)}
    it{should delegate_method(:name).to(:calendar)
      .with_prefix(true).with_arguments(allow_nil: true)}
    it{should delegate_method(:is_auto_push_to_google_calendar)
      .to(:calendar).with_prefix(true).with_arguments(allow_nil: true)}
  end

  describe "enum" do
    it {should define_enum_for(:exception_type)
      .with([:delete_only, :delete_all_follow, :edit_only,
      :edit_all_follow, :edit_all])}
    it {should define_enum_for(:repeat_type)
      .with([:daily, :weekly, :monthly, :yearly])}
  end

  describe "nested attributes" do
    it "accepts nested attributes for attendees" do
      expect accept_nested_attributes_for subject.attendees
    end

    it "accepts nested attributes for notification_events" do
      expect accept_nested_attributes_for subject.notification_events
    end

    it "accepts nested attributes for repeat_ons" do
      expect accept_nested_attributes_for subject.repeat_ons
    end
  end

  context "scopes" do
    let(:no_repeat_event) {FactoryGirl.create(:event, repeat_type: nil,
      calendar_id: calendar.id)}
    let!(:pre_nearest_events) {FactoryGirl.create(:event, start_date: 2.days.ago,
      exception_type: Event.exception_types[:edit_all_follow], calendar_id: calendar.id,
      old_exception_type: Event.exception_types[:edit_all_follow])}

    it "should return events in calendar" do
      event = double "Event"
      allow(event).to receive(:in_calendars).with([1, 2, 3])
      expect(event.in_calendars([1, 2, 3])).to be_nil
    end

    it "should return events reject with id" do
      event = double "Event"
      allow(event).to receive(:reject_with_id).with(1)
        .and_return(:object)
      expect(event.reject_with_id(1)).to eq :object
    end

    it "should return events with no repeat" do
      expect(Event.no_repeats).to eq([pre_nearest_events, no_repeat_event])
    end

    it "should return events with no exception" do
      expect(Event.has_exceptions).not_to eq([no_repeat_event, subject])
    end

    it "should return events with exception edit" do
      exception_edit_events = double("Event", parent_id: user.id,
        exception_type: 2)
      allow(exception_edit_events).to receive(:exception_edits).with(1)
        .and_return :value
      expect(exception_edit_events.exception_edits(1)).to eq :value
    end

    it "should return events with after a date" do
      after_date_events = double("Event", start_date: 2.days.ago)
      date_time_param = 1.days.ago
      allow(after_date_events).to receive(:after_date).with(date_time_param)
        .and_return :value
      expect(after_date_events.after_date(date_time_param)).to eq :value
    end

    it "should return events with pre nearest" do
      expect(Event.follow_pre_nearest(1.days.ago)).to eq([pre_nearest_events])
    end

    it "should return not delete only events" do
      expect(Event.not_delete_only).to eq([pre_nearest_events])
      expect(Event.not_delete_only).not_to eq([no_repeat_event])
    end

    it "should return old exception type events" do
      expect(Event.old_exception_type_not_null).to eq([pre_nearest_events])
      expect(Event.old_exception_type_not_null).not_to eq([no_repeat_event])
    end

    it "should return event that has calender" do
      expect(Event.of_calendar(calendar.id)).to eq([pre_nearest_events])
      expect(Event.old_exception_type_not_null).not_to eq([no_repeat_event])
    end
  end

  describe "methods" do
    start_time = 5.days.ago
    end_time = 2.days.ago
    let!(:events_exception_at_the_time) {FactoryGirl.create(:event,
      exception_type: Event.exception_types[:edit_all_follow],
      calendar_id: calendar.id, exception_time: end_time)}
    let!(:events_exception) {FactoryGirl.create(:event,
      exception_type: Event.exception_types[:delete_only],
      calendar_id: calendar.id, exception_time: end_time, parent_id: subject.id)}
    let!(:pre_nearest_events) {FactoryGirl.create(:event, start_date: 2.days.ago,
      exception_type: Event.exception_types[:edit_all_follow], calendar_id: calendar.id,
      old_exception_type: Event.exception_types[:edit_all_follow])}

    context ".event_exception_at_time" do
      it "should return event with desired exception type,
        start time and end time...." do
        expect(Event.event_exception_at_time(Event
          .exception_types[:edit_all_follow], start_time, end_time))
          .to eq events_exception_at_the_time
        expect(Event.event_exception_at_time(Event
          .exception_types[:delete_all_follow], start_time, end_time))
          .not_to eq events_exception_at_the_time
      end
    end

    context ".find_with_exception" do
      it "should return event with exception" do
        expect(Event.find_with_exception(end_time)).to eq nil
      end
    end

    context "#parent?" do
      it "should return boolean indicating it is a parent or not" do
        expect(events_exception.parent?).to be_falsy
        expect(subject.parent?).to be_truthy
        expect(subject.parent?).not_to be_falsy
      end
    end

    context "#json_data" do
      it "should return json data of a user" do
        user_event = double("Event", user_id: user.id)
        allow(user_event).to receive(:json_data).with(user.id).and_return :value
        expect(user_event.json_data(user.id)).to eq :value
      end
    end

    context "#exist_repeat?" do
      it "should return boolean indicating the event is
        repeated and it has a parent or not" do
        expect(subject.exist_repeat?).to be_falsy
      end
    end

    context "#is_repeat?" do
      it "should return boolean indicating the event is repeated or not" do
        expect(subject.is_repeat?).to be_falsy
      end
    end

    context "#old_exception_edit_all_follow?" do
      it "should return boolean indicating whether the ole exception type
        is equal to the edit_all_follow exception type" do
        expect(subject.old_exception_edit_all_follow?).to be_falsy
        expect(subject.old_exception_edit_all_follow?).not_to be_truthy
        expect(pre_nearest_events.old_exception_edit_all_follow?).to be_truthy
        expect(pre_nearest_events.old_exception_edit_all_follow?).not_to be_falsy
      end
    end

    context "#not_delete_only?" do
      it "should return boolean indicating whether the exception type is nil or
        the exception type is not delete only" do
        expect(subject.not_delete_only?).to be_truthy
        expect(subject.not_delete_only?).not_to be_falsy
      end
    end
  end
end
