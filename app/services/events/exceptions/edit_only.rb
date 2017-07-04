module Events
  module Exceptions
    class EditOnly
      def initialize event, params
        @event = event
        @params = params
      end

      def perform
        edit_all_follow_event = @event.dup if @event.edit_all_follow?

        begin
          ActiveRecord::Base.transaction do
            if edit_all_follow_event
              exception_type = Event.exception_types[:delete_only]
              old_exception_type = Event.exception_types[:edit_all_follow]
              edit_all_follow_event.update_attributes! exception_type: exception_type,
                old_exception_type: old_exception_type
            end

            @event = duplicate_event if @event.parent_id.nil?
            @event.update_attributes! event_params
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end

      private

      def event_params
        @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      end

      def duplicate_event
        event = @event.dup
        event.parent_id = @event.id
        event
      end
    end
  end
end
