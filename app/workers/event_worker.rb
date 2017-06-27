require "concern/google_api.rb"

class EventWorker
  include Sidekiq::Worker
  include GoogleApi

  def perform event_id, action
    @event = Event.find_by id: event_id
    return if @event.nil?

    @event_push = EventWorker.g_event_data @event
    @client = EventWorker.initialize_googleapi_client

    return unless %w(insert update delete).include?(action)
    send "#{action}_event"
  end

  private

  def insert_event
    @result = @client.execute(api_method: api_method(:insert),
      parameters: {calendarId: "primary"},
      body: JSON.dump(@event_push),
      headers: {"Content-Type" => "application/json"})
    @event.update_attributes google_calendar_id: @result.data.iCalUID.as_json,
      google_event_id: @result.data.id.as_json
  end

  def update_event
    @client.execute(api_method: api_method(:update),
      parameters: {calendarId: "primary", eventId: event.google_event_id},
      body: JSON.dump(@event_push),
      headers: {"Content-Type" => "application/json"})
  end

  def delete_event
    @client.execute(api_method: api_method(:delete),
      parameters: {calendarId: "primary", eventId: @event.google_event_id},
      body: JSON.dump(@event_push[:attendees]),
      headers: {"Content-Type" => "application/json"})
  end

  def api_method action
    @client.discovered_api("calendar", "v3").events.send action
  end
end
