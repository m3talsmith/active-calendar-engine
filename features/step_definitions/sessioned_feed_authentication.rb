class AceTest < ActiveCalendarEngine::Base
  has_google_options :google_service => "cl", :google_feed => "http://www.google.com/calendar/feeds/default/allcalendars/full"
end

Given /^an authenticated session is not initialized$/ do
  assert_nil AceTest.class_eval{@authenticated_session}
end

Given /^the preferences return valid credentials$/ do
  assert_kind_of Hash, AceTest.preferences
  assert_not_nil AceTest.preferences[:email]
  assert_not_nil AceTest.preferences[:password]
end

Then /^an authenticated session should be initialized when I try to authenticate the feed$/ do
  AceTest.session
  assert_not_nil AceTest.class_eval{@authenticated_session}
end
