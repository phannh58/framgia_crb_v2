module Events
  module Exceptions
    class EditOnly
      def initialize event, params
        @event = event
        @params = params
      end

      def perform
        if @event.edit_all_follow?
          event = @event.dup
          event.update(exception_type: Event.exception_types[:delete_only],
                      old_exception_type: Event.exception_types[:edit_all_follow])
        end
        save_this_event_exception
      end

      private

      def save_this_event_exception
        @event = duplicate_event if @event.parent_id.nil?
        @event.update event_params
      end

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
