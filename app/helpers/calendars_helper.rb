module CalendarsHelper
  def btn_via_permission user, event
    user_calendar = user.user_calendars.find_by calendar: event.calendar
    btn = ""
    if Settings.permissions_can_make_change.include? user_calendar.permission_id 
      btn = render "events/buttons/btn_cancel"
      btn += render "events/buttons/btn_edit", 
        url: "/users/#{user.id}/events/#{event.id}/edit";
      btn += render "events/buttons/btn_save"
      btn += render "events/buttons/btn_delete"
    elsif user_calendar.permission_id == 3
      btn = render "events/buttons/btn_detail",
        url: "/users/#{user.id}/events/#{event.id}";
    end
  end
end