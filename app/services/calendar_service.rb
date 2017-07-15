class CalendarService
  attr_accessor :events, :base_events, :user, :start_time_view, :end_time_view

  def initialize *args
    @events = []
    @base_events, @start_time_view, @end_time_view, @user = args
  end

  def repeat_data
    event_no_repeats = @base_events.select do |event|
      event.repeat_type.nil? && event.not_delete_only? && event.parent_id.nil?
    end

    event_no_repeats.each do |event|
      @events << FullCalendar::Event.new(event, @user)
    end

    (@base_events - event_no_repeats).each do |event|
      next if event.delete_only?
      generate_repeat_from_event_parent event
    end

    @events
  end

  def generate_event
    event = @base_events.first

    return [] if event.delete_only?

    if event.is_repeat? && !event.edit_only?
      generate_repeat_from_event_parent event
    else
      @events << FullCalendar::Event.new(event, @user)
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

    handle_delete_event event
    handle_edit_event event
  end

  def repeat_daily event
    repeat_dates = event.start_repeat.to_date
         .step(event.end_repeat.to_date, event.repeat_every).to_a

    repeat_dates.each do |repeat_date|
      event_temp = FullCalendar::Event.new event, @user
      event_temp.update_info(repeat_date)
      @events << event_temp
    end
  end

  def repeat_weekly event
    days_to_show = event.days_of_weeks.map(&:name)
    return if days_to_show.empty?
    repeat_dates = event.start_repeat.to_date
         .step(event.end_repeat.to_date, event.repeat_every)
         .select{|date| days_to_show.include?(date.strftime("%A"))}
    repeat_dates.each do |repeat_date|
      event_temp = FullCalendar::Event.new event, @user
      event_temp.update_info(repeat_date)
      @events << event_temp
    end
  end

  def repeat_monthly event
    repeat_dates = event.start_repeat.to_date
         .step(event.end_repeat.to_date, event.repeat_every)
         .select{|date| date.day == event.start_date.day}
    repeat_dates.each do |repeat_date|
      event_temp = FullCalendar::Event.new event, @user
      event_temp.update_info(repeat_date)
      @events << event_temp
    end
  end

  def repeat_yearly event, start, function = nil
    repeat_dates = event.start_repeat.to_date
         .step(event.end_repeat.to_date, event.repeat_every)
         .select{|date| date.day == event.start_date.day && date.month == event.start_date.month}
    repeat_dates.each do |repeat_date|
      event_temp = FullCalendar::Event.new event, @user
      event_temp.update_info(repeat_date)
      @events << event_temp
    end
  end

  def handle_delete_event event
    delete_only_events = event.event_exceptions.delete_only

    delete_only_events.each do |delete_event|
      @events.delete_if do |fevent|
        parent = fevent.event.parent ? fevent.event.parent : fevent.event
        fevent.event == event && fevent.start_date.to_date == delete_event.exception_time.to_date
      end
    end
  end

  def handle_edit_event event
    edit_only_events = event.event_exceptions.edit_only

    edit_only_events.each do |edit_event|
      @events.delete_if do |fevent|
        parent = fevent.event.parent ? fevent.event.parent : fevent.event
        fevent.event == parent && fevent.start_date.to_date == edit_event.exception_time.to_date
      end
      @events << FullCalendar::Event.new(edit_event, @user)
    end

    edit_all_follow_events = event.event_exceptions.edit_all_follow

    edit_all_follow_events.each do |edit_event|
      @events.delete_if do |fevent|
        parent = fevent.event.parent ? fevent.event.parent : fevent.event
        fevent.event == event && fevent.start_date.to_date >= edit_event.exception_time.to_date
      end
    end
  end
end
