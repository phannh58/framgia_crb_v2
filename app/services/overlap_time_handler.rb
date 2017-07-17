class OverlapTimeHandler
  ATTRS = [:overlap_time].freeze
  attr_accessor(*ATTRS)

  def initialize event = Event.new
    @event = event
    @start_time_view = (@event.start_repeat || @event.start_date).to_s
    @end_time_view = (@event.end_repeat || @event.finish_date).to_s
    @db_events = generate_db_events @event.calendar_id
    @temp_events = generate_temp_events(@event) if @db_events.any?
  end

  def valid?
    return false if @db_events.blank? || @temp_events.blank?
    return true if check_overlap_event @db_events, @temp_events
    false
  end

  private

  def check_overlap_event events, temp_events
    events.each do |event|
      temp_events.each do |temp_event|
        if compare_time? event, temp_event
          @overlap_time = event.start_date
          return true
        end
      end
    end
    false
  end

  def generate_db_events calendar_id
    events = Event.of_calendar(calendar_id).without_id event_id

    return [] if events.blank?

    calendar_service = CalendarService.new(events, @start_time_view, @end_time_view)
    calendar_service.repeat_data.select do |event|
      event.exception_type.nil? || (!event.delete_only? && !event.delete_all_follow?)
    end.sort_by(&:start_date)
  end

  def generate_temp_events event
    calendar_service = CalendarService.new([event], @start_time_view, @end_time_view)
    calendar_service.repeat_data
  end

  def compare_time? db_event, temp_event
    if db_event.all_day || temp_event.all_day
      temp_event.start_date.day == db_event.start_date.day ||
      temp_event.finish_date.day == db_event.finish_date.day
    elsif db_event.start_date.day == temp_event.start_date.day
      # follow solution at http://wiki.c2.com/?TestIfDateRangesOverlap
      (db_event.start_date < temp_event.finish_date) &&
        (temp_event.start_date < db_event.finish_date)
    end
  end

  def event_id
    @event.parent_id.nil? ? @event.id : @event.parent_id
  end
end
