module Events
  module Exceptions
    class EditAllFollow
      def initialize event, params
        @event = event
        @params = params
        @parent = @event.parent.present? ? @event.parent : @event
      end

      def perform
        handle_end_repeat_of_last_event
        handle_event_delete_only_and_old_exception_type start_date, end_repeat
        begin
          ActiveRecord::Base.transaction do
            update_event_exception_pre_nearest
            @event = duplicate_event if is_allow_duplicate_event?
            @event.update_attributes! event_params
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end

      private

      def is_allow_duplicate_event?
        return true if @event.parent_id.nil?
        return false if @event.parent_id.present? && @event.start_date.to_date == start_date.to_date
        return true if @event.edit_all_follow? && @event.start_date != start_date
      end

      def handle_end_repeat_of_last_event
        exception_events = @parent.event_exceptions
                                  .after_date(start_date.to_datetime)
                                  .order(start_date: :desc)
        return if exception_events.blank?

        load_end_repeat(exception_events)
        exception_events
      end

      def handle_event_delete_only_and_old_exception_type start_repeat, end_repeat
        event_exceptions = @parent.event_exceptions
                                  .delete_only
                                  .old_exception_type_not_null
                                  .in_range(start_repeat, end_repeat)
        event_exceptions.each{|event| event.update old_exception_type: nil}
      end

      def update_event_exception_pre_nearest
        events = @parent.event_exceptions
                        .follow_pre_nearest(start_date)
                        .order(start_date: :desc)
        event = !events.empty? ? events.first : @parent
        event.update(end_repeat: (start_date.to_date - 1.day))
      end

      def load_end_repeat exception_events
        events_edit_all_follow = exception_events.edit_all_follow
        delete_only = exception_events.delete_only.old_exception_edit_all_follow

        # @params[:event][:end_repeat] =
        #   if events_edit_all_follow.present?
        #     events_edit_all_follow.first.end_repeat
        #   elsif delete_only.present?
        #     delete_only.first.end_repeat
        #   end
      end

      def event_params
        @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      end

      def duplicate_event
        event = @event.dup
        event.parent_id = @event.id
        event
      end

      def start_date
        event_params[:start_date]
      end

      def end_repeat
        event_params[:end_repeat]
      end
    end
  end
end
