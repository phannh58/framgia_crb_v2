module UpdateEditAll
  attr_accessor :params, :event, :event_handler

  private

  def check_edit_all params, event, event_handler
    @params = params
    @event = event
    @event_handler = event_handler
    parse_time_to_params_update
    @params
  end

  def range_time_parent_day
    if @event.daily?
      @event.repeat_every.days
    elsif @event.weekly?
      @event.repeat_every.weeks
    elsif @event.monthly?
      @event.repeat_every.months
    else
      @event.repeat_every.year
    end
  end

  def change_time event_time, other_datetime
    event_time.change(hour: other_datetime.hour, min: other_datetime.min, sec: other_datetime.sec)
  end

  def parse_time_with_old_exception
    @event.old_exception_type = nil
    @event.exception_type = nil
    start_date_parent = @event.start_date + range_time_parent_day
    finish_date_parent = @event.finish_date + range_time_parent_day
    @params[:event][:start_date] = change_time(start_date_parent, @event_handler.start_date)
    @params[:event][:finish_date] = change_time(finish_date_parent, @event_handler.finish_date)
  end

  def parse_time_without_old_exception
    @params[:event][:start_date] = change_time(@event.start_date, @event_handler.start_date)
    @params[:event][:finish_date] = change_time(@event.finish_date, @event_handler.finish_date)
  end

  def parse_time_to_params_update
    if @event.old_exception_type.blank?
      parse_time_without_old_exception
    else
      parse_time_with_old_exception
    end
  end
end
