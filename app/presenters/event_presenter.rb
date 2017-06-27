class EventPresenter
  attr_reader :object, :start_date, :finish_date, :range_time_title, :locals

  delegate :title, :calendar_name, :attendees, :owner_name, :description,
    to: :object, allow_nil: true

  def initialize event, params
    @object = event
    @params = params
    make_data
  end

  def make_data
    make_local_data
    make_range_time_title
  end

  def fdata
    Base64.urlsafe_encode64(@locals)
  end

  private

  def stime_name
    @start_date.strftime("%I:%M%p")
  end

  def ftime_name
    @finish_date.strftime("%I:%M%p")
  end

  def dsname
    @start_date.strftime("%A")
  end

  def dstime_name
    @start_date.strftime("%d-%m-%Y")
  end

  def dfname
    @finish_date.strftime("%A")
  end

  def dftime_name
    @start_date.strftime("%m-%d-%Y")
  end

  def make_range_time_title
    @range_time_title = @start_date.strftime("%B %-d %Y")
    return if @object.all_day?

    @range_time_title = dsname + " " + stime_name + " To " +
                        ftime_name + " " + dstime_name
    return if is_one_day?

    @range_time_title = [dsname, stime_name, dstime_name].join(" ") + " To " +
                        [dfname, ftime_name, dftime_name].join(" ")
  end

  def make_local_data
    @start_date = build_start_date
    @finish_date = build_finish_date
    @locals ||= {
      event_id: @object.id,
      start_date: @start_date,
      finish_date: @finish_date
    }.to_json
  end

  def is_one_day?
    @start_date.strftime("%A") == @finish_date.strftime("%A")
  end

  def build_start_date
    return @params[:start_date].to_datetime if @params[:start_date].present?
    @object.start_date
  end

  def build_finish_date
    return @params[:finish_date].to_datetime if @params[:finish_date].present?
    @object.finish_date
  end
end
