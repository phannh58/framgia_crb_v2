require File.expand_path(File.join(File.dirname(__FILE__), "..",
  "support", "paths"))

Given(/^I am on (.+)$/) do |page_name|
  visit path_to(page_name)
end

Given(/^I am signed in into the system as "([^"]*)"$/) do |email|
  @user = Fabricate :user, name: "test", email: email, password: "12345678"
  Fabricate :setting, owner_id: @user.id, owner_type: User.name
  login_as @user, scope: :user
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |attribute, value|
  fill_in(attribute, with: value)
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |value, selector|
  select value, from: selector
end

When(/^I check the "([^"]*)" checkbox$/) do |checkbox|
  element = find checkbox
  expect(element).not_to be_nil
  element.set true
end

# To test javascript select2 selector
When(/^I choose "([^"]*)" from "([^"]*)" selector$/) do |option, selector2|
  find(selector2, visible: :all).click
  within ".select2-results" do
    find("li", text: option).click
  end
end

# To test javascript datepicker; date = "current" for Date.today
When(/^I select "([^"]*)" date in "([^"]*)"$/) do |date, datepicker|
  find(datepicker).click
  expect(page).to have_css("div#ui-datepicker-div")
  date = DateTime.now.strftime("%e/%m/%Y") if date == "current"
  day, month, year = date.split("/")
  within "#ui-datepicker-div" do
    month_span = find "span.ui-datepicker-month"
    expect(month_span).not_to be_nil
    year_span = find "span.ui-datepicker-year"
    expect(year_span).not_to be_nil
    next_month = find "a.ui-datepicker-next.ui-corner-all"
    expect(next_month).not_to be_nil
    prev_month = find "a.ui-datepicker-prev.ui-corner-all"
    expect(next_month).not_to be_nil
    select_desired_month_of_year year, year_span, month, month_span, next_month,
      prev_month
    cell = find "td", text: day
    expect(cell).not_to be_nil
    cell.click
  end
end

# To test javascript timekeeper
When(/^I select "([^"]*)" time in "([^"]*)"$/) do |time, timepicker|
  find(timepicker).click
  expect(page).to have_css "div.ui-timepicker-wrapper"
  within ".ui-timepicker-wrapper" do
    cell = first "li", text: time
    expect(cell).not_to be_nil
    cell.click
  end
end

When(/^I press "([^"]*)"$/) do |button|
  click_button button
end
