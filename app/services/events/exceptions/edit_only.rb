module Events
  module Exceptions
    class EditOnly
      def initialize user, event, params
        @user = user
        @event = event
        @params = params
        @temp_event = Event.new event_params.delete_if{|key, _| key == :repeat_ons_attributes}
      end

      def perform
        return false if changed_event_repeat_time?

        begin
          ActiveRecord::Base.transaction do
            if @event.edit_all_follow? || (@event.exception_type.nil? && changed_event_time?)
              delete_event = @event.dup
              delete_event.parent_id = @event.parent_id || @event.id
              delete_event.user_id = @user.id

              exception_type = Event.exception_types[:delete_only]

              if @event.edit_all_follow?
                old_exception_type =  Event.exception_types[:edit_all_follow]
              end

              delete_event.update_attributes! exception_type: exception_type,
                exception_time: @params[:start_time_before_change],
                start_date: @params[:start_time_before_change],
                finish_date: @params[:finish_time_before_change],
                old_exception_type: old_exception_type
            end

            new_event = edited_self? ? @event : @event.dup
            new_event.user_id = @user.id

            if @params[:specific_form] == 1
              make_and_assign_attendees new_event
              make_and_assign_notifications new_event
            end

            if changed_event_time?
              new_event.update_attributes! event_params.merge({
                start_repeat: nil, end_repeat: nil, repeat_type: nil,
                repeat_every: nil, exception_time: nil, exception_type: nil,
                notification_events_attributes: []
              })
            else
              new_event.update_attributes event_params.merge({
                parent_id: @event.parent_id || @event.id,
                start_repeat: nil, end_repeat: nil,
                repeat_type: nil, repeat_every: nil,
                notification_events_attributes: []
              })
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

      def changed_event_time?
        event = Event.new start_date: @params[:start_time_before_change],
          finish_date: @params[:finish_time_before_change]
        @temp_event.start_date != event.start_date || @temp_event.finish_date != event.finish_date
      end

      def changed_event_repeat_time?
        return if @event.persisted? && @event.start_repeat.nil? || @event.end_repeat.nil?
        @temp_event.start_date.to_date != @temp_event.start_repeat.to_date || @temp_event.end_repeat.to_date != @event.end_repeat.to_date
      end

      def edited_self?
        @event.start_date == @temp_event.start_repeat
      end

      def attendee_emails
        return [] if @params[:attendee].blank?
        return @params[:attendee][:emails]
      end

      def make_and_assign_attendees event
        users = User.where(email: attendee_emails).select(:email, :id)
        attendees = Attendee.where(email: attendee_emails)
        emails = users.map(&:email) + attendees.map(&:email)

        users.each do |user|
          attendees += [Attendee.find_or_initialize_by(user_id: user.id)]
        end

        attendee_emails.each do |email|
          next if emails.include?(email)
          attendees += [Attendee.new(email: email)]
        end
        event.attendees = attendees.uniq
      end

      def make_and_assign_notifications event
        event.notification_events = @temp_event.notification_events
      end
    end
  end
end
