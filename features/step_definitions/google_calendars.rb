class CalendarTest < ActiveCalendarEngine::Base
  has_google_options :google_service => "cl", :google_feed => "http://www.google.com/calendar/feeds/default/allcalendars/full"
end

# -- Scenario: An array of Calendars will be retrieved using an authenticated token
When /^I do a find all$/ do
  @calendars = Calendar.find(:all)
end

Then /^I should have an array of calendars$/ do
  assert_kind_of Array, @calendars
  assert @calendars.length > 0
end
# --

# -- Scenario: A calendar, chosen from an array of calendars, is valid --
When /^I retrieve a list of calendars$/ do
  @calendars = Calendar.find(:all)
end

When /^I look at the first calendar$/ do
  @calendar = @calendars.first
end

Then /^It should have all it's attributes and the timezone should not be nil:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    assert @calendar.respond_to?(hash['attributes']), "@calendar does not respond to #{hash['attributes']}"
    assert_not_nil hash['attributes'] if hash['attributes'] == "timezone"
  end
end
# --