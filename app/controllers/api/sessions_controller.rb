module Api
  class SessionsController < Api::BaseController
    skip_before_action :authenticate_with_token!
    respond_to :json

    def create
      user = User.find_by email: request[:email]

      if user.present? && user.valid_password?(request[:password])
        user.generate_authentication_token!
        user.save
        render_with_user user
      else
        render json: {errors: I18n.t("api.invalid_email_or_password")}, status: 422
      end
    end

    private

    def render_with_user user
      render json: {
        message: I18n.t("api.login_success"),
        user: user.as_json(include: %i(user_calendars shared_calendars))
      }, status: :ok
    end
  end
end
