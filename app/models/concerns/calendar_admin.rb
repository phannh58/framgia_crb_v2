module CalendarAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :creator
        field :name
        field :owner
        field :address
        field :description
        field :number_of_seats
        field :workspace_id
        field :google_calendar_id
        field :color
        field :status
        field :is_default
        field :is_auto_push_to_google_calendar
        field :is_allow_overlap
        field :users
      end
    end
  end
end
