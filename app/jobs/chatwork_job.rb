ChatworkJob = Struct.new(:event)

class ChatworkJob
  def perform
    send_notification_messages
  end

  private

  def send_notification_messages
    @owner = User.find_by id: event.user_id
    return unless @owner
    make_chatwork_message @owner, Settings.chatwork_room_id, @owner.chatwork_id
  end

  def send_notifiaction_message_to_attendees
    event.attendees.each do |attendee|
      make_chatwork_message attendee, Settings.chatwork_room_id, attendee.chatwork_id
    end
  end

  def make_chatwork_message user, room_id, chatwork_id
    ChatWork::Message.create(room_id: room_id,
        body: "[To:#{chatwork_id}] #{user.name}
        #{I18n.t('events.message.event_start', event: event.title)}")
  end
end
