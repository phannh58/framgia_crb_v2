class ChatworkJob < Struct.new(:event)
  def perform
    send_notification_messages
  end

  private

  def send_notification_messages
    @owner = User.find_by id: event.user_id
    ChatWork::Message.create(room_id: Settings.chatwork_room_id,
        body: "[To:#{@owner.chatwork_id}] #{@owner.name}
        #{I18n.t('events.message.event_start', event: event.title)}")

    event.attendees.each do |attendee|
      ChatWork::Message.create(room_id: Settings.chatwork_room_id,
        body: "[To:#{attendee.chatwork_id}] #{attendee.user_name}
        #{I18n.t('events.message.event_start', event: event.title)}")
    end
  end
end
