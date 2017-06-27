module FullCalendar
  class EventSerializer < ActiveModel::Serializer
    include SharedMethods

    attributes(*SHARE_ATTRIBUTES)

    # belongs_to :owner
    # has_many :notification_events
    # belongs_to :calendar
  end
end
