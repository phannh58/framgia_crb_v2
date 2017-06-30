class NullUser
  attr_reader :id, :name, :email

  def initialize org = nil
    @name = I18n.t "user_name"
    @org = org
  end

  def other_calendars
    Calendar.none
  end

  def manage_calendars
    Calendar.none
  end

  def user_calendars
    UserCalendar.none
  end

  def persisted?
    false
  end

  def setting_default_view
    @org.try :setting_default_view || "scheduler"
  end

  def setting_timezone_name
    @org.try :setting_timezone_name
  end

  Permission.permission_types.each_key do |permission_type|
    define_method("can_#{permission_type}?") do |_calendar|
      return false
    end
  end
end
