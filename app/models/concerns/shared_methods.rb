module SharedMethods
  extend ActiveSupport::Concern
  SHARE_ATTRIBUTES = [:id, :title, :description, :color_id, :all_day,
    :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date,
    :finish_date, :start_repeat, :end_repeat, :exception_time, :exception_type,
    :event_id, :persisted, :calendar_name, :editable].freeze

  def user_context
    current_user || NullUser.new
  end
end
