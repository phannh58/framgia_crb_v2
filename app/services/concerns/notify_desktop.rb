module NotifyDesktop
  private

  def notify_desktop_event event, action_name
    @event = event
    case action_name
    when Settings.create_event
      send_notify I18n.t("events.notification.remind_create_event")
    when Settings.start_event
      send_notify I18n.t("events.notification.remind_start_event")
    when Settings.delete_event
      send_notify I18n.t("events.notification.remind_delete_event")
    when Settings.delete_all_following_event
      send_notify I18n.t("events.notification.remind_delete_all_following_event")
    when Settings.delete_all_event
      send_notify I18n.t("events.notification.remind_delete_all_event")
    when Settings.edit_event
      send_notify I18n.t("events.notification.remind_edit_event")
    when Settings.edit_all_following_event
      send_notify I18n.t("events.notification.remind_edit_all_following_event")
    when Settings.edit_all_event
      send_notify I18n.t("events.notification.remind_edit_all_event")
    end
  end

  def send_notify message
    @message = message
    make_broadcast_message "notification_channel_#{event.owner.cable_token}"

    @event.attendees.each do |attendee|
      notify_data[:to_user] = attendee.user_name
      make_broadcast_message "notification_channel_#{attendee.user.cable_token}"
    end
  end

  def notify_data
    {
      title: @event.title,
      start: @event.start_date.strftime(Settings.event.format_datetime),
      finish: @event.finish_date.strftime(Settings.event.format_datetime),
      desc: @event.description,
      attendees: @event.attendees.map(&:user_name).join(", "),
      from_user: @event.owner.name,
      remind_message: @message,
      icon: ActionController::Base.helpers.asset_path(Settings.notification.icon),
      path: Rails.application.routes.url_helpers.event_path(@event)
    }
  end

  def make_broadcast_message channel
    ActionCable.server.broadcast channel, notify_data: notify_data
  end
end
