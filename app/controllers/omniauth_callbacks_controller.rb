class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  def create
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
      sign_in_and_redirect @user
    else
      flash[:notice] = "Auth failure"
      redirect_to root_path
    end
  end

  def failure
    flash[:notice] = "Auth failure"
    redirect_to root_path
  end

  alias facebook create
  alias google_oauth2 create
  alias hr_system create
end
