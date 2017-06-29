NotificationDesktopJob = Struct.new(:event, :action_name)

class NotificationDesktopJob
  include NotifyDesktop

  def perform
    notify_desktop_event event, action_name
  end
end
