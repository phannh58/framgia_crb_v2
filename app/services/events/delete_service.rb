module Events
  class DeleteService
    include MakeActivity

    EXCEPTION_TYPE = %w(delete_only delete_all_follow delete_all).freeze

    def initialize user, event, params
      @event = event
      @params = params
      @user = user
      @exception_type = @params[:exception_type] || @event.exception_type
      @exception_time = @params[:exception_time] || @event.exception_time
    end

    def perform
      return false if @exception_time.blank? || @exception_type.blank?
      send @exception_type
    end

    private

    def delete_only
      Events::Exceptions::DeleteOnly.new(@event, @params).perform
    end

    def delete_all_follow
      Events::Exceptions::DeleteAllFollow.new(@event, @params).perform
    end

    def delete_all
      Events::Exceptions::DeleteAll.new(@event).perform
    end
  end
end
