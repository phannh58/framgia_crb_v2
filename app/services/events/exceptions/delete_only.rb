module Events
  module Exceptions
    class DeleteOnly
      def initialize event, params
        @event = event
        @params = params
      end

      def perform
         begin
          ActiveRecord::Base.transaction do
            if delete_root_event?
              @event.start_date = new_start_date
              @event.finish_date = new_finish_date
              @event.start_repeat = @event.start_date
              @event.save!
            else
              new_event = @event.dup
              new_event.exception_time = @params[:exception_time]
              new_event.exception_type = :delete_only
              new_event.parent_id = @event.parent ? @event.parent_id : @event.id
              new_event.save!
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

      def new_start_date
        @event.start_date + range_time_parent_day
      end

      def new_finish_date
        @event.finish_date + range_time_parent_day
      end

      def range_time_parent_day
        return @event.repeat_every.days if @event.daily?
        return @event.repeat_every.weeks if @event.weekly?
        return @event.repeat_every.months if @event.monthly?
        @event.repeat_every.year
      end
    end
  end
end
