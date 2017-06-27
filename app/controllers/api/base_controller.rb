module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session

    include Authenticable

    skip_before_action :authenticate_user!
    before_action :authenticate_with_token!
  end
end
