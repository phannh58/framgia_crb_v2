class MultiEventsController < ApplicationController
  def create
    calendar_ids = params[:calendar_ids]
    start_date = params[:start_date]
    finish_date = params[:finish_date]

    begin
      ActiveRecord::Base.transaction do
        calendar_ids.map do |calendar_id|
          Event.create! calendar_id: calendar_id,
            start_date: start_date,
            finish_date: finish_date
        end
      end
    rescue
      @object = e.record
    end

    if @object.blank?
      flash[:success] = t "events.flashs.created"
      redirect_to root_path
    else
      redirect_back(fallback_location: root_path)
    end
  end
end
