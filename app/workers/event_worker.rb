require "concern/google_api.rb"

class EventWorker
  include Sidekiq::Worker
  include GoogleApi

  def perform event_id, action
    @event = Event.find_by id: event_id
    return if @event.nil?

    @google_calendar = @event.calendar.google_calendar_id
    @event_push = EventWorker.g_event_data @event
    @client = EventWorker.initialize_googleapi_client

    return unless %w(insert update delete).include?(action)
    send "#{action}_event"
  end

  private

  def insert_event
    @client.insert_event(@google_calendar, @event_push, send_notifications: true) do |res, err|
      if err
        # Handle error
      else
        @event.update_attributes google_event_id: res.i_cal_uid
      end
    end
  end

  def update_event
    @client.update_event(@google_calendar, @event.google_event_id, @event_push) do |res, err|
      if err
        # Handle error
      end
    end
  end

  def delete_event
    @client.delete_event(@google_calendar, @event.google_event_id) do |res, err|
      if err
        # Handle error
      end
    end
  end
end
