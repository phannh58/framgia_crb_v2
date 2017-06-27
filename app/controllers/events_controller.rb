class EventsController < ApplicationController
  include Responsable::Event
  load_resource except: %i(index new create)
  authorize_resource
  skip_before_action :authenticate_user!, only: %i(index show)
  before_action :load_calendars, :build_event_params, only: %i(new edit)
  before_action only: %i(edit update destroy) do
    validate_permission_change_of_calendar @event.calendar
  end
  before_action only: :show do
    validate_permission_see_detail_of_calendar @event.calendar
  end

  serialization_scope :current_user

  def index
    @events = Event.in_calendars params[:calendar_ids]

    if user_signed_in? && params[:organization_id].blank?
      @events += Event.shared_with_user current_user
    end

    @events = CalendarService.new(@events, params[:start_time_view],
      params[:end_time_view], context_user).repeat_data

    render json: @events, each_serializer: FullCalendar::EventSerializer,
      root: :events,
      adapter: :json,
      meta: t("api.request_success"),
      meta_key: :message,
      status: :ok
  end

  def show
    @event_presenter = EventPresenter.new(@event, params)
    respond_to do |format|
      format.html
      format.json do
        render json: {
          popup_content: render_to_string(partial: "events/popup",
            formats: :html,
            layout: false,
            locals: {event_presenter: @event_presenter})
        }
      end
    end
  end

  def new
    @event =
      if params[:event][:event_id]
        Event.find(params[:event][:event_id]).dup
      else
        Event.new event_params
      end

    load_related_data
  end

  def create
    service = Events::CreateService.new current_user, params
    respond_to do |format|
      if service.perform
        response_create_success(service, format)
      else
        response_create_fail(service, format)
      end
    end
  end

  def edit
    if params[:fdata]
      @event.start_date = event_params["start_date"]
      @event.finish_date = build_finish_date(event_params)
    end
    load_related_data
  end

  def update
    service = Events::UpdateService.new current_user, @event, params
    respond_to do |format|
      if service.perform
        response_update_success service, format
      else
        response_update_fail service, format
      end
    end
  end

  def destroy
    service = Events::DeleteService.new current_user, @event, params
    respond_to do |format|
      response_destroy service, format
    end
  end

  private

  def event_params
    params.require(:event).permit Event::ATTRIBUTES_PARAMS
  end

  def load_calendars
    @calendar_presenter = CalendarPresenter.new context_user
    @calendars = current_user.manage_calendars
  end

  def load_related_data
    Notification.all.each do |notification|
      @event.notification_events.find_or_initialize_by notification: notification
    end

    DaysOfWeek.all.each do |days_of_week|
      @event.repeat_ons.find_or_initialize_by days_of_week: days_of_week
    end

    @repeat_ons = @event.repeat_ons.sort_by(&:days_of_week_id)
  end

  def build_finish_date hparams
    return @event.start_date.end_of_day if @event.all_day?
    hparams["finish_date"]
  end

  def build_event_params
    if params[:fdata].blank?
      params[:event] = {title: ""}
      return
    end

    begin
      response = JSON.parse(Base64.decode64(params[:fdata]))
      params[:event] = response
    rescue JSON::ParserError
      params[:event] = {title: ""}
    end
  end
end
