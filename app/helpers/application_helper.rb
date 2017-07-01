# The application do
module ApplicationHelper
  def title page_title
    content_for :title, page_title.to_s
  end

  def flash_class level
    case level
    when :notice then "alert-info"
    when :error then "alert-error"
    when :alert, :danger then "alert-warning"
    when :success then "alert-success"
    end
  end

  def datetime_format object, format
    return nil if object.blank?
    l(object.in_time_zone(current_user.setting_timezone_name),
      format: t("events.time.formats.#{format}"))
  end

  def is_edit_form? param
    param == "edit"
  end

  def resource_name
    :user
  end

  def resource
    # instance_variable_get(:"@#{resource_name}")
    @user = current_user || User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_class
    User
  end

  def controller_class
    controller_name.split("_").join("-")
  end

  def link_to_add_fields field, association
    new_object = field.object.class.reflect_on_association(association).klass.new
    fields = field.fields_for(association, new_object,
      child_index: t(".new") + association.to_s) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to t(".add_workspace"), "javascript:void(0)", class: "btn btn-primary",
      onclick: "add_fields(this,\"#{association}\", \"#{escape_javascript(fields)}\")"
  end

  def context_user
    current_user || NullUser.new(@organization)
  end

  def go_back_link
    if cookies[:back].blank?
      root_path
    else
      cookie = cookies[:back]
      cookie = cookie[0, cookie.length - 1]
      cookie.split("\;").last
    end
  end
end
