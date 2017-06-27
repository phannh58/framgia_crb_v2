module CalendarsHelper
  def btn_via_permission user, event, fdata = nil
    user_calendar = user.user_calendars.find_by calendar: event.calendar
    return if user_calendar.nil?

    # btn = render "events/buttons/btn_copy", url: "/events/new?fdata=#{fdata}"
    # btn = "" if event.calendar.is_default? || user_calendar.permission_id == 4
    if Settings.permissions_can_make_change.include? user_calendar.permission_id
      render "events/buttons/btn_can_make_change", event: event, fdata: fdata
    elsif user_calendar.permission_id == 3
      render "events/buttons/btn_detail", url: "/events/#{event.id}"
    end
  end

  def link_via_permission event, fdata = nil
    user_calendar = current_user.user_calendars.find_by calendar: event.calendar
    return if user_calendar.permission_id == 4

    if Settings.permissions_can_make_change.include? user_calendar.permission_id
      link = render "events/links/link_view", url: "/events/#{event.id}"
      link += render "events/links/link_edit", url: "/events/#{event.id}/edit?fdata=#{fdata}"
    elsif user_calendar.permission_id == 3
      link = render "events/links/link_view", url: "/events/#{event.id}"
    end
    link
  end

  def confirm_popup_repeat_events action
    render "events/confirm_popup_repeat", action: action
  end

  def is_event_controller?
    params[:controller] == "events"
  end

  def is_new_action?
    %w(new create).include? action_name
  end
end
