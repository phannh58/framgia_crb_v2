module UserAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :name
        field :display_name
        field :slug
        field :email
        field :avatar
        field :password
        field :password_confirmation
        field :chatwork_id
        field :token
        field :uid
        field :provider
        field :email_require
        field :organizations
        field :calendars
        field :teams
        field :setting
      end
    end
  end
end
