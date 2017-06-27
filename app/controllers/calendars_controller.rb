class CalendarsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  load_and_authorize_resource except: :index
  before_action :load_colors, except: %i(show destroy)
  before_action :load_users, :load_permissions, only: %i(new edit)
  before_action :load_user_calendar, only: %i(edit update)
  before_action :find_owner, only: :create
  before_action only: %i(edit update) do
    unless current_user.permission_manage? @calendar
      flash[:alert] = t("flash.messages.not_permission")
      redirect_to root_path
    end
  end

  def index
    @organization = Organization.find_by slug: params[:organization_id]
    @calendar_presenter = CalendarPresenter.new context_user, @organization
    @event = Event.new if user_signed_in?
  end

  def create
    @calendar.creator_id = current_user.id
    @calendar.owner = @owner

    if @calendar.save
      ShareCalendarService.new(@calendar).share_sub_calendar
      redirect_to root_path, flash: {success: t("calendar.success_create")}
    else
      load_users
      load_permissions
      load_owners
      flash.now[:alert] = t "calendar.danger_create"
      render :new
    end
  end

  def new
    load_owners
    @calendar.color = @colors.sample
  end

  def edit
    @user_selected = User.find_by email: params[:email] if params[:email]
  end

  def update
    @calendar.status = "no_public" unless calendar_params[:status]

    if @calendar.update_attributes calendar_params
      ShareCalendarService.new(@calendar).share_sub_calendar
      redirect_to root_path, flash: {success: t("calendar.success_update")}
    else
      render :edit
    end
  end

  def destroy
    if @calendar.destroy
      flash[:success] = t "calendars.deleted"
    else
      flash[:alert] = t "calendars.not_deleted"
    end
    redirect_to root_path
  end

  private

  def calendar_params
    params.require(:calendar).permit Calendar::ATTRIBUTES_PARAMS
  end

  def load_colors
    @colors = Color.all
  end

  def load_users
    @users = User.all
  end

  def load_permissions
    @permissions = Permission.all
  end

  def load_user_calendar
    @user_calendar = @calendar.user_calendars.find_by user_id: current_user.id
  end

  def find_owner
    case params[:owner_type]
    when Organization.name
      @owner = Organization.find_by slug: params[:owner_id]
    when User.name
      @owner = User.find_by slug: params[:owner_id]
    end
  end

  def load_owners
    @owners = [[current_user.name, current_user.name, {"data-owner-type" => "User"}]]
    @owners += current_user.organizations.map do |org|
      [org.name, org.name, {"data-owner-type" => "Organization"}]
    end
  end
end
