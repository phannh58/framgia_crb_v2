Rails.application.routes.draw do
  # Serve websocket cable requests in-process
  mount ActionCable.server => "/cable"

  get "search_user/index"
  get "/api"  => "application#api"

  devise_for :users,
    controllers: {
      omniauth_callbacks: "omniauth_callbacks",
      sessions: "sessions",
      registrations: "registrations"
    }

  authenticated :user do
    root "calendars#index"
  end

  unauthenticated :user do
    root "home#show", as: :unauthenticated_root
  end

  resources :search, only: [:index]
  resources :users, only: :show
  resources :calendars do
    collection do
      get :search, to: "calendars/search#show"
    end
  end
  resources :share_calendars, only: :new
  resources :events
  resource :multi_events, only: [:create]
  resources :attendees, only: [:create, :destroy]
  resources :particular_calendars, only: [:show, :update]
  resources :organizations, path: "orgs" do
    resources :activities, only: [:index]
    resources :calendars, only: [:index]
    resource :invite, only: :show
    resource :invitation do
      get ":id/edit", action: :edit, as: :member
      patch ":id", action: :update
      delete ":id", action: :destroy
    end
    resources :teams
  end
  resources :user_organizations

  namespace :api do
    resources :calendars, only: [:update, :new]
    resources :users, only: :index
    resources :events, except: [:edit, :new]
    resources :request_emails, only: :new
    get "search" => "searches#index"
    resources :sessions, only: [:create, :destroy]
  end
  resource :check_names, only: :show
end
