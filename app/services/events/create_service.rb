module Events
  class CreateService
    include MakeActivity
    attr_accessor :is_overlap, :event

    ATTRIBUTES_PARAMS = [:title, :description, :status, :color, :all_day,
      :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date,
      :finish_date, :start_repeat, :end_repeat, :exception_type, :exception_time,
      attendees_attributes: [:email, :_destroy, :user_id],
      repeat_ons_attributes: [:days_of_week_id, :_destroy],
      notification_events_attributes: [:notification_id, :_destroy]].freeze
    REPEAT_PARAMS = [:repeat_type, :repeat_every, :start_repeat, :end_repeat,
      :repeat_ons_attributes].freeze

    def initialize user, params
      @user = user
      @params = params
    end

    def perform
      modify_repeat_params if @params[:repeat].blank?
      @event = @user.events.build event_params

      return false if is_overlap? && !@event.calendar.is_allow_overlap?

      if status = @event.save
        NotificationWorker.perform_async @event.id
        make_activity @user, @event, :create
      end
      status
    end

    private

    def event_params
      @params.require(:event).permit ATTRIBUTES_PARAMS
    end

    def modify_repeat_params
      REPEAT_PARAMS.each{|attribute| @params[:event].delete attribute}
    end

    def is_overlap?
      overlap_time_handler = OverlapTimeHandler.new @event
      self.is_overlap = overlap_time_handler.valid?
    end
  end
end
