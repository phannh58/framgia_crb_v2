Given(/^I create an event with certain start time and end time$/) do
  Fabricate :event, start_date: DateTime.new(2017,7,20,22,0,0), 
    finish_date: DateTime.new(2017,7,20,23,0,0), user_id: User.last.id,
    calendar: Calendar.last, repeat_type: nil, repeat_every: nil
end

When(/^I select repeat settings as "([^"]*)"$/) do |repeat_type|
  expect(page).to have_css("div#dialog-repeat-event-form")
  within "#dialog-repeat-event-form" do
    select_from_selectbox "select#event_repeat_type", repeat_type
    select_from_selectbox "select#event_repeat_every", "2"
    endtime = find "input#end-date-repeat" 
    endtime.set "30-09-2017"
    find("div.ep-recl-dialog-title").click
    find("div.done-repeat.goog-imageless-button-content.btn.btn-default").click
  end
end

Then(/^I have an event with title "([^"]*)" and user_id (\d+) and calendar_id (\d+)$/) do |title, user_id, calendar_id|
  expect(Event.count).to eq 1
  expect(Event.last.title).to eq title
  expect(Event.last.user_id.to_s).to eq user_id
  expect(Event.last.calendar_id.to_s).to eq calendar_id
end

Then(/^I should find a error box with "([^"]*)"$/) do |name|
  element = find name
  expect(element).not_to be_nil
end

Then(/^I have an event with title "([^"]*)" and user_id (\d+) and calendar_id (\d+) and all day set "([^"]*)"$/) do |title, user_id, calendar_id, all_day|
  expect(page).to have_content "My Calendars"
  expect(Event.count).to eq 1
  expect(Event.last.title).to eq title
  expect(Event.last.user_id.to_s).to eq user_id
  expect(Event.last.calendar_id.to_s).to eq calendar_id
  expect(Event.last.all_day.to_s).to eq all_day
end

When(/^I have an event with title "([^"]*)" and repeat settings$/) do |title|
  expect(page).to have_content "My Calendars"
  expect(Event.count).to eq 1
  expect(Event.last.title).to eq title
  expect(Event.last.user_id).to eq 1
  expect(Event.last.calendar_id).to eq 1
  expect(Event.last.repeat_type).to eq "monthly"
  expect(Event.last.repeat_every).to eq 2
  expect(Event.last.start_repeat).not_to be_nil
  expect(Event.last.end_repeat).not_to be_nil
end
