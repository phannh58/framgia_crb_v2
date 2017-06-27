module Events
  class UpdateService
    include MakeActivity

    attr_accessor :is_overlap, :event

    REPEAT_PARAMS = [:repeat_type, :repeat_every, :start_repeat, :end_repeat,
      :repeat_ons_attributes].freeze
    HANDLE_ATTRIBUTES_PARAMS = [:all_day, :repeat_type, :repeat_every,
      :calendar_id, :start_date, :finish_date, :start_repeat, :end_repeat,
      :exception_type, :exception_time].freeze

    def initialize user, event, params
      @user = user
      @event = event
      @params = params
      @event_handler = Event.new handle_event_params
    end

    def perform
      nhash = {
        exception_time: event_params[:start_date],
        start_repeat: start_repeat,
        end_repeat: end_repeat
      }
      @params[:event] = @params[:event].merge(nhash)

      if changed_time? && is_overlap? && !@event.calendar.is_allow_overlap?
        return false
      else
        exception_service = Events::ExceptionService.new(@event, @params)

        if exception_service.perform
          @event = exception_service.new_event
          make_activity @user, @event, :update
          return true
        else
          return false
        end
      end
    end

    private

    def event_params
      @params.require(:event).permit Event::ATTRIBUTES_PARAMS
    end

    def handle_event_params
      if @params[:repeat].blank?
        REPEAT_PARAMS.each{|attribute| @params[:event].delete attribute}
      end
      @params.require(:event).permit HANDLE_ATTRIBUTES_PARAMS
    end

    def is_overlap?
      @event_handler.parent_id = @event.parent? ? @event.id : @event.parent_id
      @event_handler.calendar_id = @event.calendar_id
      overlap_time_handler = OverlapTimeHandler.new(@event_handler)
      self.is_overlap = overlap_time_handler.valid?
    end

    def start_repeat
      event_params[:start_repeat] || event_params[:start_date]
    end

    def end_repeat
      event_params[:end_repeat] || @event.end_repeat
    end

    def changed_time?
      return false if @event_handler.start_date.nil?
      @event.start_date != @event_handler.start_date
    end
  end
end
