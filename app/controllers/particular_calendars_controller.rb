class ParticularCalendarsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :load_calendar, only: %i(show)

  def show
    @calendar_presenter = CalendarPresenter.new context_user, nil
    @colors = Color.all
    @event = Event.new if user_signed_in?
  end

  def update
    @user_calendar = UserCalendar.find_by user: context_user, calendar_id: params[:id]

    respond_to do |format|
      if @user_calendar && @user_calendar.update(user_calendar_params)
        format.json{render json: @user_calendar}
      else
        format.json{render json: {}, status: :unauthorized}
      end
      format.html{redirect_to root_path}
    end
  end

  private

  def load_calendar
    @calendar = Calendar.find_by(id: params[:id]) || NullCalendar.new

    return if @calendar.share_public?

    flash[:danger] = "You don't have any permissions!!!"
    redirect_to root_path
  end

  def user_calendar_params
    params.require(:user_calendar).permit UserCalendar::ATTR_PARAMS
  end
end
