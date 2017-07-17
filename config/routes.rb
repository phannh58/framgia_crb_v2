Rails.application.routes.draw do
  devise_for :admins, path: "admin", controllers: {
      sessions: "admin/sessions",
      passwords: "admin/passwords"
    }

  authenticate :admin do
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end

  mount RailsAdmin::Engine => "/admin", as: "rails_admin"

  # Serve websocket cable requests in-process
  mount ActionCable.server => "/cable"

  get "/api"  => "application#api"

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks",
      sessions: "sessions",
      registrations: "registrations",
      passwords: "passwords"
    }

  authenticated :user do
    root "calendars#index"
  end

  unauthenticated :user do
    root "home#show", as: :unauthenticated_root
  end

  resources :search, only: %i(index)
  resources :users, only: %i(show) do
    collection do
      get :search
    end
  end
  resources :calendars do
    collection do
      get :search, to: "calendars/search#show"
    end
  end
  resources :events
  resource :multi_events, only: %(create)
  resources :attendees, only: %i(create destroy)
  resources :particular_calendars, only: %i(show update)
  resources :organizations, path: "orgs" do
    resources :teams
    resources :activities, only: %i(index)
    resources :members, only: %i(index)
    resources :calendars, only: %i(index)
    resource :invitations, only: %i(show create update destroy) do
      get ":id/edit", action: :edit, as: :member
    end
  end

  namespace :api do
    resources :calendars, only: %i(update new)
    resources :users, only: %(index)
    resources :events, except: %i(edit new)
    resources :request_emails, only: %i(new)
    get "search" => "searches#index"
    resources :sessions, only: %i(create destroy)
  end
  resource :check_names, only: %i(show)
end
