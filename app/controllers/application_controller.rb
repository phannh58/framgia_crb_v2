class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ApplicationHelper

  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :store_location
  before_action :create_back_cookie, unless: "request.xhr?"

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to unauthenticated_root_path
  end

  def api
    str = File.open(Rails.root.join("doc", "api.md")).read

    str.gsub!(":event_id", Event.all.sample.id.to_s)
       .gsub!(":auth_token", User.all.sample.auth_token)

    str = BlueCloth.new(str).to_html
    render text: to_html(str, "Room Booking API")
  end

  protected

  def authenticate_user! opts = {}
    if current_user
      super
    else
      redirect_to unauthenticated_root_path,
        alert: t("devise.failure.unauthenticated")
    end
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: User::ATTR_PARAMS
    devise_parameter_sanitizer.permit :account_update, keys: User::ATTR_PARAMS
  end

  def validate_permission_change_of_calendar calendar
    return true if context_user.can_make_changes_and_manage_sharing?(calendar)
    return true if context_user.can_make_changes_to_events?(calendar)

    respond_to do |format|
      format.html{redirect_to root_path, flash: {alert: "You don't have permission for this!!!"}}
      format.json{render json: {status: 401, message: "You don't have permission for this!!!"}, status: 401}
    end
  end

  def validate_permission_see_detail_of_calendar calendar
    return true unless context_user.can_make_changes_and_manage_sharing?(calendar)
    return true unless context_user.can_make_changes_to_events?(calendar)
    return true unless context_user.can_see_all_event_details?(calendar)
    return true if calendar.share_public?

    respond_to do |format|
      format.html{redirect_to root_path, flash: {alert: "You don't have permission for this!!!"}}
      format.json{render json: {status: 401, message: "You don't have permission for this!!!"}, status: 401}
    end
  end

  def store_location
    return if ["/users/sign_in", "/users/sign_up", "/users/password/new",
               "/users/password/edit", "/users/confirmation",
               "/users/sign_out"].include?(request.path)
    return if request.xhr?

    session["user_return_to"] = request.fullpath
  end

  def create_back_cookie
    cookies[:back] ||= ""
    cookies[:return] ||= ""
    cookies[:back] += request.referer + ";" if
      request.referer && cookies[:return] != request.referer
    cookies[:return] = request.referer
  end

  def after_sign_in_path_for resource
    sign_in_url = new_user_session_url

    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end

  def to_html str, title
    <<-HTML
      <html lang="en">
        <head>
          <title>#{title}</title>
          <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
        </head>
        <body style="background: #fff;">
          <div class="container">
            #{str}
          </div>
        </body>
      </html>
    HTML
  end
end
