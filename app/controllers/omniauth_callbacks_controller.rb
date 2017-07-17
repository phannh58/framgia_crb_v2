class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  def create
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      set_flash_message(:notice, :success, kind: auth.provider) if is_navigational_format?
      sign_in @user

      if @user.changed_password?
        redirect_to root_path
      else
        redirect_to edit_user_registration_path
      end
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
  alias framgia create
end
