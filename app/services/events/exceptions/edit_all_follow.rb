module Events
  module Exceptions
    class EditAllFollow
      def initialize user, event, params
        @user = user
        @event = event
        @params = params
        @parent = @event.parent ? @event.parent : @event
        @temp_event = Event.new event_params
      end

      def perform
        return false if changed_start_repeat?
        return false if @temp_event.end_repeat < @temp_event.start_repeat

        begin
          ActiveRecord::Base.transaction do
            # Find all end after date @temp_event.start_date
            load_events_after_start_date.each{|event| event.destroy!}

            if (@temp_event.end_repeat > @event.end_repeat) || changed_event_time?
              # # Update end repeat of parent event
              # @parent.update_attributes! end_repeat: (@temp_event.start_date - 1.day)
              # Creat new evert with new repeat
              @temp_event.assign_attributes exception_time: nil,
                exception_type: nil,
                calendar_id: @event.calendar_id,
                repeat_every: @event.repeat_every,
                repeat_type: @event.repeat_type,
                title: @event.title,
                user_id: @user.id
              @temp_event.save!
            else
              unless @event.edit_all_follow?
                # update_event_exception_pre_nearest
                @event = duplicate_event if is_allow_duplicate_event?
              end
              @event.user_id = @user.id
              @event.update_attributes! event_params
            end
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end

      private

      def is_allow_duplicate_event?
        return true if @event.parent_id.nil?
        return true if @event.edit_all_follow? && @event.start_date != start_date
      end

      def load_events_after_start_date
        @parent.event_exceptions.after_date(start_date.to_datetime)
                                .order(start_date: :desc)
      end

      def update_event_exception_pre_nearest
        events = @parent.event_exceptions
                        .follow_pre_nearest(start_date)
                        .order(start_date: :desc)
        event = !events.empty? ? events.first : @parent
        event.update(end_repeat: (start_date.to_date - 1.day))
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
        @temp_event.start_date
      end

      def end_repeat
        @temp_event.end_repeat
      end

      def changed_start_repeat?
        @temp_event.start_repeat.to_date != @temp_event.start_date.to_date
      end

      def changed_event_time?
        event = Event.new start_date: @params[:start_time_before_change],
          finish_date: @params[:finish_time_before_change]
        event.start_date != @temp_event.start_date || event.finish_date != @temp_event.finish_date
      end
    end
  end
end
