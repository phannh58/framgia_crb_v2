module Events
  class ExceptionService
    attr_accessor :event

    EXCEPTION_TYPE = %w(edit_only edit_all edit_all_follow).freeze

    def initialize event, params
      @event = event
      @params = params
      @event_params = @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      @exception_type = @event_params[:exception_type]
      @exception_time = @event_params[:exception_time]
      @start_time_before_drag = @params[:start_time_before_drag]
      @finish_time_before_drag = @params[:finish_time_before_drag]
      @persisted = @params[:persisted]
      @parent = @event.parent.present? ? @event.parent : @event
    end

    def perform
      if @exception_type.in?(EXCEPTION_TYPE)
        perform_with_exception
      # elsif @event.is_repeat?
      #   perform_with_repeat
      else
        @event.update_attributes @event_params
      end
    end

    private

    def perform_with_exception
      return false if @exception_time.blank?
      return false if Event.find_with_exception @exception_time.to_datetime.utc
      send @exception_type
    end

    def perform_with_repeat
      create_event_when_drop
      @event.delete_only! if @parent
      create_event_with_exception_delete_only
    end

    def is_drop?
      @params[:is_drop].to_i == 1
    end

    def create_event_when_drop
      %i(exception_type exception_time).each{|k| @event_params.delete k}
      @event_params[:start_repeat] = @event_params[:start_date]
      @event_params[:end_repeat] = @event_params[:finish_date]
      @event = duplicate_event
      %i(repeat_type repeat_every google_event_id google_calendar_id).each do |attribute|
        @event.send("#{attribute}=", nil)
      end
      @event.update_attributes @event_params.permit!
    end

    def create_event_with_exception_delete_only
      @event_params[:parent_id] = @event.id
      @event_params[:exception_type] = Event.exception_types[:delete_only]
      @event_params[:start_date] = @start_time_before_drag
      unless @event_params[:all_day] == "1"
        @event_params[:finish_date] = @finish_time_before_drag
      end
      @event_params[:exception_time] = @start_time_before_drag
      @event.dup.update_attributes @event_params.permit!
    end

    def edit_only
      Events::Exceptions::EditOnly.new(@event, @params).perform
    end

    def edit_all_follow
      Events::Exceptions::EditAllFollow.new(@event, @params).perform
    end

    def edit_all
      Events::Exceptions::EditAll.new(@event, @params).perform
    end

    def duplicate_event
      event = @event.dup
      event.parent_id = @event.id
      event
    end
  end
end
