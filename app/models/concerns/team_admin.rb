module TeamAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      edit do
        field :name
        field :description
        field :organization
        field :users
      end
    end
  end
end
