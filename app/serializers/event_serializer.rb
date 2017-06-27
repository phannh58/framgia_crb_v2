class EventSerializer < ActiveModel::Serializer
  include SharedMethods

  attributes(*SHARE_ATTRIBUTES)

  # has_many :attendees
  # has_many :users, through: :attendees
  # has_many :days_of_weeks
  # has_many :event_exceptions, class_name: Event.name, foreign_key: :parent_id
  # has_many :notification_events

  # belongs_to :calendar
  # belongs_to :owner, class_name: User.name, foreign_key: :user_id
  # belongs_to :event_parent, class_name: Event.name, foreign_key: :parent_id

  def event_id
    object.id
  end

  def id
    Event.generate_unique_secure_token.downcase!
  end

  def color_id
    object.calendar.get_color(user_context.id)
  end

  def editable
    true
  end

  def persisted
    true
  end
end
