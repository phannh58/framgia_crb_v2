class RoomSearchService
  include ActiveModel::Validations

  validates_presence_of :start_time, :finish_time
  validate :start_time_is_after_finish_time, if: "start_time.present? && finish_time.present?"

  attr_accessor :start_time, :finish_time, :manage_calendars, :calendar_ids,
    :number_of_seats

  def initialize user, params
    @user = user
    @params = params
    @calendars = user.manage_calendars
    @manage_calendars = @calendars.map{|calendar| [calendar.name, calendar.id]}
    assign_data
  end

  def perform
    calendars = load_calendars
    all_events = load_all_events_from_calendars @calendar_ids
    results = []

    calendars.each do |calendar|
      events = load_events all_events, calendar.id

      if check_room_is_empty?(events)
        results << ResultSearchPresenter.new(:empty, calendar, @start_time, @finish_time)
      else
        next if (time_suggests = suggest_time events).blank?
        time_suggests.each do |time_suggest|
          results << ResultSearchPresenter.new(:suggest, calendar,
            time_suggest[:start_time], time_suggest[:finish_time])
        end
      end
    end
    results
  end

  def is_selected_all_calendars?
    @calendars.ids.to_set == @calendar_ids.to_set
  end

  private

  def load_calendars
    calendars = @calendars.select{|calendar| calendar.id.in?(@calendar_ids)}
    return calendars if @number_of_seats == Settings.number_of_seats.zero

    calendars = calendars.select do |calendar|
      calendar.number_of_seats.nil? || (calendar.number_of_seats && calendar.number_of_seats >= @number_of_seats)
    end.compact

    calendars
  end

  def load_all_events_from_calendars calendar_ids
    events = Event.in_calendars calendar_ids, @start_time, @finish_time
    calendar_service = CalendarService.new events, @start_time, @finish_time
    calendar_service.repeat_data
  end

  def load_events all_events, calendar_id
    events = all_events.select{|event| event.calendar_id == calendar_id}
    events.compact!
    return [] if events.blank?
    events.sort_by(&:start_date)
  end

  def suggest_time events
    delta = @finish_time.to_time - @start_time.to_time
    suggest_results = []
    events.each_with_index do |event, index|
      temp = (@start_time.to_time - event.start_date).abs
      next if temp > Settings.limited_suggest_time.hours

      suggest_start_time = event.start_date - delta
      suggest_finish_time = event.finish_date + delta

      suggest_time_before_event = suggest_time_before_event events, index, suggest_start_time
      suggest_time_after_event = suggest_time_after_event events, index, suggest_finish_time
      suggest_results << suggest_time_before_event if suggest_time_before_event.present?
      suggest_results << suggest_time_after_event if suggest_time_after_event.present?
    end
    suggest_results
  end

  def suggest_time_before_event events, index, suggest_start_time
    if index.zero? || suggest_start_time >= events[index - 1].finish_date
      {
        start_time: suggest_start_time,
        finish_time: events[index].start_date
      }
    end
  end

  def suggest_time_after_event events, index, suggest_finish_time
    if index == (events.size - 1) || suggest_finish_time <= events[index + 1].start_date
      {
        start_time: events[index].finish_date,
        finish_time: suggest_finish_time
      }
    end
  end

  def check_room_is_empty? events
    return true if events.size.zero?
    is_empty = true
    events.each do |event|
      next if event.nil? || @start_time >= event.finish_date || @finish_time <= event.start_date
      is_empty = false
      break
    end
    is_empty
  end

  def start_time_is_after_finish_time
    if @start_time >= @finish_time
      errors.add(:time_errors, I18n.t("room_search.input_time_error"))
    end
  end

  def assign_data
    if @params[:event_start_date].present?
      @start_time = @params[:event_start_date]
    end

    if @params[:event_finish_date].present?
      @finish_time = @params[:event_finish_date]
    end

    @calendar_ids = selected_calendars
    @number_of_seats = @params[:number_of_seats].to_i
  end

  def selected_calendars
    calendar_ids = @params[:calendar_ids]
    calendar_ids.blank? ? @calendars.ids : calendar_ids.map(&:to_i)
  end
end
