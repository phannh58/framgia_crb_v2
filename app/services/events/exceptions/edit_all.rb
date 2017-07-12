module Events
  module Exceptions
    class EditAll
      def initialize event, params
        @event = event
        @params = params
        @parent = @event.parent.present? ? @event.parent : @event
        @temp_event = Event.new event_params
      end

      def perform
        return false if changed_start_repeat?
        return false if @temp_event.end_repeat < @parent.start_repeat

        begin
          ActiveRecord::Base.transaction do
            if changed_repeat_type?
              @parent.event_exceptions.each{|event| event.destroy!}
              @parent.update_attributes event_params.merge({
                exception_time: nil, exception_type: nil,
                start_date: @parent.start_date, finish_date: @parent.finish_date,
                start_repeat: @parent.start_repeat
              })
            else
              # TÌm thằng gốc và update thông tin cho nó
              @parent.update_attributes! event_params.merge({
                exception_time: nil, exception_type: nil,
                start_date: @parent.start_date, finish_date: @parent.finish_date,
                start_repeat: @parent.start_repeat, end_repeat: @parent.end_repeat
              })

              # TÌm tất cả những thằng có excepton không phải là delete và update thêm thông tin cho nó
              @parent.event_exceptions.not_delete_only.each do |event|
                event.assign_attributes title: @parent.title,
                  description: @parent.description
                event.notifications = event.notifications + @parent.notifications
                event.attendees = event.attendees + @parent.attendees
                event.save!
              end
            end
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end

      private

      def event_params
        @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      end

      def changed_repeat_type?
        return false if @temp_event.repeat_type.nil?
        @temp_event.repeat_type != @parent.repeat_type
      end

      def changed_start_repeat?
        @temp_event.start_repeat.to_date != @temp_event.start_date.to_date
      end
    end
  end
end
