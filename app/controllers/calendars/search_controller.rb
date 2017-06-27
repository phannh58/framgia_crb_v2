module Calendars
  class SearchController < ApplicationController
    def show
      @calendar_presenter = CalendarPresenter.new(current_user)
      @room_search = RoomSearchService.new current_user, params
      @results = @room_search.perform if @room_search.valid?
    end
  end
end
