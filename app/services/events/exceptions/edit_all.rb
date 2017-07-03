module Events
  module Exceptions
    class EditAll
      def initialize event, params
        @event = event
        @params = params
        @parent = @event.parent.present? ? @event.parent : @event
      end

      def perform
        handle_end_repeat_of_last_event
        @exception_events = load_event_delete_only_and_old_exception_type

        @event = @parent
        @params[:event].delete :exception_type if @event.delete_only?
        @params[:event].delete :start_repeat

        begin
          ActiveRecord::Base.transaction do
            @exception_events.each{|event| event.update! old_exception_type: nil}
            @event.update! event_params
          end
        rescue
        end
      end

      private

      def event_params
        @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      end

      def handle_end_repeat_of_last_event
        @exception_events = @parent.event_exceptions
                                  .after_date(start_date.to_datetime)
                                  .order(start_date: :desc)
        return if @exception_events.blank?
        @params[:event][:end_repeat] = reassign_end_repeat
      end

      def load_event_delete_only_and_old_exception_type
        @parent.event_exceptions.delete_only
                                .old_exception_type_not_null
                                .in_range(start_repeat, end_repeat)
      end

      def reassign_end_repeat
        event_edit_all_follow = @exception_events.edit_all_follow.first
        return events_edit_all_follow.end_repeat if event_edit_all_follow
        delete_only = @exception_events.delete_only
                                       .old_exception_edit_all_follow.first
        return delete_only.end_repeat if delete_only
      end

      def start_date
        @params[:event][:start_date]
      end

      def start_repeat
        @params[:event][:start_repeat]
      end

      def end_repeat
        @params[:event][:end_repeat]
      end
    end
  end
end
