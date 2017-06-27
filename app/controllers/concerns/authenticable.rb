module Authenticable
  include ActionController::HttpAuthentication::Token

  def current_user
    authentication_token = params[:auth_token] || request.env["HTTP_AUTH_TOKEN"]
    @current_user ||= User.find_by(auth_token: authentication_token)
  end

  def authenticate_with_token!
    return if user_signed_in?

    render json: {errors: "Not authenticated"}, status: :unauthorized
  end

  def user_signed_in?
    current_user.present?
  end
end
