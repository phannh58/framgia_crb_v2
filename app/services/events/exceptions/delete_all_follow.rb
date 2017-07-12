module Events
  module Exceptions
    class DeleteAllFollow
      def initialize event, params
        @event = event
        @params = params
      end

      def perform
         begin
          ActiveRecord::Base.transaction do
            if delete_root_event?
              @event.destroy!
            else
              event_exceptions = @event.event_exceptions
                                       .after_date(@params[:exception_time].to_datetime)
              event_exceptions.each{|event| event.destroy!}
              @event.update_attributes! end_repeat: @params[:exception_time]
            end
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end

      private

      def delete_root_event?
        temp_event = Event.new start_date: @params[:exception_time]
        @event.parent? && @event.start_date == temp_event.start_date
      end
    end
  end
end
