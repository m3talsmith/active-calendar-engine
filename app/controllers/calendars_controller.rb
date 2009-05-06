class CalendarsController < ApplicationController
  def index
    @calendars = Calendar.find(:all)
  end
  
  def show
    @calendar = Calendar.find(params[:id])
    logger.debug @calendar
  end
end
