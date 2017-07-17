module OrganizationAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :creator
        field :name
        field :display_name
        field :slug
        field :logo
        field :users
        field :teams
        field :calendars
        field :workspaces
        field :setting
      end
    end
  end
end
