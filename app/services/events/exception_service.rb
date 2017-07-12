module Events
  class ExceptionService
    attr_accessor :event

    EXCEPTION_TYPE = %w(edit_only edit_all edit_all_follow).freeze

    def initialize user, event, params
      @user = user
      @event = event
      @params = params
      @exception_type = event_params[:exception_type] || @event.exception_type
      @exception_time = event_params[:exception_time] || @event.exception_time
    end

    def perform
      if @exception_type.in?(EXCEPTION_TYPE)
        return perform_with_exception
      end

      @event.update_attributes event_params
    end

    private

    def perform_with_exception
      return false if @exception_time.blank?
      return false if Event.find_with_exception @exception_time.to_datetime.utc
      return false if @exception_type.blank?
      send @exception_type
    end

    def edit_only
      Events::Exceptions::EditOnly.new(@user, @event, @params).perform
    end

    def edit_all_follow
      Events::Exceptions::EditAllFollow.new(@user, @event, @params).perform
    end

    def edit_all
      Events::Exceptions::EditAll.new(@event, @params).perform
    end

    def event_params
      @params.require(:event).permit Event::ATTRIBUTES_PARAMS
    end
  end
end
