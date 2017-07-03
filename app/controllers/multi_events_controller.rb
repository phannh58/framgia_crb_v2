class MultiEventsController < ApplicationController
  before_action :make_multi_events

  def create
    if @object.blank?
      flash[:success] = t "events.flashs.created"
      redirect_to root_path
    else
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def calendar_ids
    params[:calendar_ids]
  end

  def start_date
    params[:start_date]
  end

  def finish_date
    params[:finish_date]
  end

  def make_multi_events
    begin
      ActiveRecord::Base.transaction do
        calendar_ids.each(&create_event_block)
      end
    rescue Exception => e
      @object = e.record
    end
  end

  def create_event_block
    proc do |calendar_id|
      Event.create! calendar_id: calendar_id, start_date: start_date, finish_date: finish_date
    end
  end
end
