module Notifier
  class ChatworkServices
    def initialize event
      @event = event
    end

    def perform
      send_messages
    end

    private

    def send_messages
      @time_at = @event.start_date.strftime Settings.event.format_datetime
      @owner = User.find_by id: @event.user_id

      make_chatwork_message(@owner.name, Settings.chatwork_room_id, @owner.chatwork_id)

      @event.attendees.each do |attendee|
        next if attendee.chatwork_id.blank?
        make_chatwork_message(attendee, Settings.chatwork_room_id, attendee.chatwork_id)
      end
    end

    def make_chatwork_message user_name, room_id, chatwork_id
      ChatWork::Message.create(
        room_id: room_id,
        body: "[To:#{chatwork_id}] #{user_name}
        #{I18n.t('events.message.chatwork_create', event: @event.title, time: @time_at)}"
      )
    end

    # def create_tasks
    #   if @event.chatwork_room_id && @event.attendees
    #     unix_time_limit = Time.parse(@event.start_date.to_s).to_i
    #     ChatWork::Task.create(
    #       room_id: @event.chatwork_room_id,
    #       body: @event.task_content,
    #       to_ids: chatwork_ids,
    #       limit: unix_time_limit
    #     )
    #   end
    # end

    # def chatwork_ids
    #   @event.attendees.map(&:chatwork_id).join(", ")
    # end
  end
end
