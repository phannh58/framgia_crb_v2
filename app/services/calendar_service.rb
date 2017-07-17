class CalendarService
  attr_accessor :events, :base_events, :user, :start_time_view, :end_time_view

  def initialize *args
    @events = []
    @base_events, @start_time_view, @end_time_view, @user = args
    @start_time_view = DateTime.parse(@start_time_view)
    @end_time_view = DateTime.parse(@end_time_view)
  end

  def repeat_data
    event_no_repeats = @base_events.select do |event|
      event.repeat_type.nil? && event.not_delete_only? && event.parent_id.nil?
    end

    event_no_repeats.each do |event|
      @events << FullCalendar::Event.new(event, @user)
    end

    (@base_events - event_no_repeats).each do |event|
      next if event.parent
      generate_repeat_from_event_parent event
      handle_edit_all_follow_event event
      handle_delete_event event
      handle_edit_only_event event
    end

    @events
  end

  private

  def generate_repeat_from_event_parent event
    if event.repeat_daily?
      repeat_daily event
    elsif event.repeat_weekly?
      repeat_weekly event
    elsif event.repeat_monthly?
      repeat_monthly event
    elsif event.repeat_yearly?
      repeat_yearly event
    end
  end

  def repeat_daily event
    repeat_dates = event.start_repeat.to_date
         .step(event.end_repeat.to_date, event.repeat_every).to_a

    repeat_dates.each do |repeat_date|
      make_and_assign_event event, repeat_date
    end
  end

  def repeat_weekly event
    days_to_show = event.days_of_weeks.map(&:name).uniq
    return if days_to_show.empty?

    repeat_dates = start_week_number(event).step(finish_week_number(event), event.repeat_every).map do |week_number|
      days_in_week = Settings.event.repeat_data
      days_to_show.map{|day| Date.commercial(@start_time_view.year, week_number, days_in_week.index(day) + 1)}
    end.flatten

    repeat_dates.each do |repeat_date|
      make_and_assign_event event, repeat_date
    end
  end

  def repeat_monthly event
    start_repeat = event.start_repeat
    end_repeat = event.end_repeat
    number_months = (end_repeat.year * 12 + end_repeat.month) - (start_repeat.year * 12 + start_repeat.month) + 1

    repeat_dates = []
    number_months.times.each do |index|
      next if (index % event.repeat_every != 0)
      repeat_date = event.start_date + index.months

      next if (repeat_date < @start_time_view || repeat_date > @end_time_view || repeat_date > event.end_repeat)
      repeat_dates << repeat_date
    end

    repeat_dates.each do |repeat_date|
      make_and_assign_event event, repeat_date
    end
  end

  def repeat_yearly event
    number_years = event.end_repeat.year - event.start_repeat.year + 1

    repeat_dates = []
    number_years.times.each do |index|
      next if (index % event.repeat_every != 0)
      repeat_date = event.start_date + index.years

      next if (repeat_date < @start_time_view || repeat_date > @end_time_view || repeat_date > event.end_repeat)
      repeat_dates << repeat_date
    end

    repeat_dates.each do |repeat_date|
      make_and_assign_event event, repeat_date
    end
  end

  def handle_delete_event event
    delete_only_events = event.event_exceptions.delete_only

    delete_only_events.each do |delete_event|
      @events.delete_if do |fevent|
        fevent.event.parent_id == delete_event.parent_id && fevent.start_date.to_date == delete_event.exception_time.to_date
      end
    end
  end

  def handle_edit_all_follow_event event
    edit_all_follow_events = event.event_exceptions.edit_all_follow

    edit_all_follow_events.each do |edit_event|
      @events.delete_if do |fevent|
        fevent.event.id == edit_event.parent_id && fevent.start_date.to_date >= edit_event.exception_time.to_date
      end

      generate_repeat_from_event_parent edit_event
    end
  end

  def handle_edit_only_event event
    edit_only_events = event.event_exceptions.edit_only

    edit_only_events.each do |edit_event|
      @events.delete_if do |fevent|
        fevent.event.parent_id == edit_event.parent_id && fevent.start_date.to_date == edit_event.exception_time.to_date
      end
      @events << FullCalendar::Event.new(edit_event, @user)
    end
  end

  private

  def start_week_number event
    if @start_time_view > event.start_repeat
      @start_time_view.strftime("%U").to_i
    else
      event.start_repeat.strftime("%U").to_i
    end
  end

  def finish_week_number event
    if @end_time_view < event.end_repeat
      @end_time_view.strftime("%U").to_i
    else
      event.end_repeat.strftime("%U").to_i
    end
  end

  def make_and_assign_event event, date
    event_temp = FullCalendar::Event.new event, @user
    event_temp.update_info(date)
    @events << event_temp
  end
end
