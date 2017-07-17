class RegistrationsController < Devise::RegistrationsController
  skip_before_action :authenticate_user!, only: [:create]
  respond_to :json

  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        handle_with_active_resource resource
      else
        handle_without_active_resource resource
      end
    else
      handle_without_resource resource
    end
  end

  protected

  def update_resource resource, params
    if resource.changed_password?
      resource.update_with_password params
    elsif resource.update_attributes params
      resource.update_attributes changed_password: true
      bypass_sign_in resource
    end
  end

  def after_update_path_for resource
    user_path resource
  end

  def handle_without_resource resource
    clean_up_passwords resource
    messages = resource.errors.messages

    if request.xhr?
      return render json: {success: false, data: {message: messages}}
    end
    respond_with resource
  end

  def handle_with_active_resource resource
    message = find_message(:signed_up)
    flash[:notice] = message
    sign_up(resource_name, resource)

    if request.xhr?
      return render json: {success: true, data: {message: message}}
    end
    respond_with resource, location: after_sign_up_path_for(resource)
  end

  def handle_without_active_resource resource
    message = find_message(:"signed_up_but_#{resource.inactive_message}")
    expire_data_after_sign_in!

    if request.xhr?
      return render json: {success: true, data: {message: message}}
    end
    respond_with resource, location: after_inactive_sign_up_path_for(resource)
  end
end
