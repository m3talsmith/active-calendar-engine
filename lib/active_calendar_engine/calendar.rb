module ActiveCalendarEngine
  class Calendar < ActiveCalendarEngine::Base
    has_google_options :google_service => "cl", :google_feed => "http://www.google.com/calendar/feeds/default/allcalendars/full"
  end
end