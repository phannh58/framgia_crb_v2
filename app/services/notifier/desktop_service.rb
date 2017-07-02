module Notifier
  DesktopService = Struct.new(:event, :action_name)
  class DesktopService
    include NotifyDesktop

    def perform
      notify_desktop_event event, action_name
    end
  end
end
