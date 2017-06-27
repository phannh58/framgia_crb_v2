module FullCalendar
  class Event
    alias_method :read_attribute_for_serialization, :send
    include SharedMethods

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self)
    end

    ATTRS = [:id, :color_id, :start_date, :finish_date, :event_id, :calendar_id,
      :calendar_name, :persisted, :event, :editable].freeze

    attr_accessor *ATTRS

    delegate :title, :description, :status, :all_day,
      :delete_only?, :delete_all_follow?,
      :repeat_type, :repeat_every, :user_id, :start_repeat, :end_repeat,
      :exception_time, :exception_type, to: :event, allow_nil: true

    def initialize event, user
      @event = event
      @user = user || NullUser.new
      assign_attributes
    end

    def update_info repeat_date
      @start_date = @start_date.change(day: repeat_date.day,
        month: repeat_date.month,
        year: repeat_date.year)
      @finish_date = @finish_date.change(day: repeat_date.day,
        month: repeat_date.month,
        year: repeat_date.year)
      @id = ::Event.generate_unique_secure_token.downcase!
      @persisted = @event.start_date == @start_date
    end

    private
    def valid_permission_user_in_calendar?
      user_calendar = UserCalendar.find_by(calendar: @calendar, user: @user)
      return false if user_calendar.nil?
      Settings.permissions_can_make_change.include? user_calendar.permission_id
    end

    def assign_attributes
      @start_date = @event.start_date
      @finish_date = @event.finish_date
      @calendar = @event.calendar
      @calendar_name = @calendar.name
      @calendar_id = @calendar.id
      @id = ::Event.generate_unique_secure_token.downcase!
      @event_id = @event.id
      @editable = valid_permission_user_in_calendar?
      @persisted = true
      @color_id = @event.calendar.get_color(@user.id)
    end
  end
end
