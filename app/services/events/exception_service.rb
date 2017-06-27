module Events
  class ExceptionService
    attr_accessor :new_event

    EXCEPTION_TYPE = %w(edit_only edit_all edit_all_follow)

    def initialize event, params
      @event = event
      @params = params
      @event_params = @params.require(:event).permit Event::ATTRIBUTES_PARAMS
      @exception_type = @event_params[:exception_type]
      @start_time_before_drag = @params[:start_time_before_drag]
      @finish_time_before_drag = @params[:finish_time_before_drag]
      @persisted = @params[:persisted]
      @parent = @event.event_parent.present? ? @event.event_parent : @event
    end

    def perform
      if @exception_type.in?(EXCEPTION_TYPE)
        unless Event.find_with_exception @event_params[:exception_time].to_datetime.utc
          send @exception_type
        end
      elsif @event.is_repeat?
        #  || (@event.parent.present? &&
        # @event.start_date.to_date != @event_params[:start_date].to_date)
        #  if only change time
        #   create new item with new time
        #  if change date before
        # create new delete only item
        # create new item with new date time
        self.new_event = create_event_when_drop
        @event.delete_only! if @event.event_parent.present?
        create_event_with_exception_delete_only
      else
        if @event.update_attributes @event_params
          @event_after_update = @event
          self.new_event = @event
          return true
        else
          return false
        end
      end

      # if @event_after_update.present?
        # argv =  {
        #   event_before_update_id: @event.id,
        #   event_after_update_id: @event_after_update.id,
        #   start_date_before: @start_time_before_drag,
        #   finish_date_before: @finish_time_before_drag,
        #   action_type: :update_event
        # }
        # EmailWorker.perform_async argv
        # if @event_params[:exception_type] == "edit_all"
        #   Notifier::DesktopService.new(@event_after_update,
        #     Settings.edit_all_event).perform
        # elsif @event_params[:exception_type] == "edit_all_follow"
        #   Notifier::DesktopService.new(@event_after_update,
        #     Settings.edit_all_following_event).perform
        # else
        #   Notifier::DesktopService.new(@event_after_update,
        #     Settings.edit_event).perform
        # end
      # end
    end

    private
    def is_drop?
      @params[:is_drop].to_i == 1
    end

    def save_this_event_exception event
      if event.event_parent.present?
        @event_after_update = event
      else
        @event_after_update = @event.dup
        @event_after_update.parent_id = @event.id
      end

      attribute_params = [:title, :description, :status, :color, :all_day,
        :repeat_type, :repeat_every, :user_id, :calendar_id, :start_date,
        :finish_date, :start_repeat, :end_repeat, :exception_type, :exception_time,
        attendees_attributes: [:email, :_destroy, :user_id],
        repeat_ons_attributes: [:days_of_week_id, :_destroy],
        notification_events_attributes: [:notification_id, :_destroy]].freeze

      @event_after_update.update @params.require(:event).permit attribute_params
      self.new_event = @event_after_update
    end

    def event_exception_pre_nearest
      events = @parent.event_exceptions
        .follow_pre_nearest(@event_params[:start_date]).order(start_date: :desc)
      events.size > 0 ? events.first : @parent
    end

    def create_event_when_drop
      [:exception_type, :exception_time].each{|k| @event_params.delete k}
      @event_params[:start_repeat] = @event_params[:start_date]
      @event_params[:end_repeat] = @event_params[:finish_date]

      @event_after_update = @event.dup
      @event_after_update.parent_id = @event.id
      [:repeat_type, :repeat_every, :google_event_id, :google_calendar_id]
        .each{|attribute| @event_after_update.send("#{attribute}=", nil)}
      @event_after_update.update_attributes @event_params.permit!
      @event_after_update
    end

    def create_event_with_exception_delete_only
      @event_params[:parent_id] = @event.id
      @event_params[:exception_type] = Event.exception_types[:delete_only]
      @event_params[:start_date] = @start_time_before_drag
      unless @event_params[:all_day] == "1"
        @event_params[:finish_date] = @finish_time_before_drag
      end
      @event_params[:exception_time] = @start_time_before_drag
      @event.dup.update_attributes @event_params.permit!
    end

    def edit_only
      if @event.edit_all_follow?
        event_dup = @event.dup
        event_dup.update(exception_type: "delete_only",
          old_exception_type: Event.exception_types[:edit_all_follow])
      end
      save_this_event_exception @event
    end

    def edit_all_follow
      exception_events = handle_end_repeat_of_last_event
      start_date = @event_params[:start_date]
      end_date = @event_params[:end_repeat]
      handle_event_delete_only_and_old_exception_type start_date, end_date
      save_this_event_exception @event
      event_exception_pre_nearest
        .update(end_repeat: (@event_params[:start_date].to_date - 1.day))
    end

    def edit_all
      @event_after_update = @parent
      handle_end_repeat_of_last_event
      start_date = @event_params[:start_date]
      end_date = @event_params[:end_repeat]
      handle_event_delete_only_and_old_exception_type start_date, end_date
      self.new_event = update_attributes_event @parent
    end

    def update_attributes_event event
      @event_params.delete :exception_type if event.delete_only?
      @event_params.delete :start_repeat
      event.update_attributes @event_params.permit!
      event
    end

    def handle_end_repeat_of_last_event
      exception_events = @parent.event_exceptions
        .after_date(@event_params[:start_date].to_datetime)
        .order(start_date: :desc)

      events_edit_all_follow = exception_events.edit_all_follow
      delete_only = exception_events.delete_only.old_exception_edit_all_follow

      return if exception_events.blank?

      if events_edit_all_follow.present?
        @event_params[:end_repeat] = events_edit_all_follow.first.end_repeat
      elsif delete_only.present?
        @event_params[:end_repeat] = delete_only.first.end_repeat
      end
      exception_events
    end

    def handle_event_delete_only_and_old_exception_type start_repeat, end_repeat
      event_exceptions = @parent.event_exceptions.delete_only
        .old_exception_type_not_null.in_range(start_repeat, end_repeat)
      event_exceptions.each{|event| event.update old_exception_type: nil}
    end
  end
end
