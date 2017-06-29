module Events
  class CreateService
    include MakeActivity
    attr_accessor :is_overlap, :event

    REPEAT_PARAMS = %i(repeat_type repeat_every start_repeat end_repeat repeat_ons_attributes).freeze

    def initialize event, params
      @event = event
      @params = params
    end

    def perform
      modify_repeat_params if @params[:repeat].blank?

      return false if is_overlap? && !@event.calendar.is_allow_overlap?

      if (status = @event.save)
        NotificationWorker.perform_async @event.id
        make_activity @event.owner, @event, :create
      end
      status
    end

    private

    def modify_repeat_params
      REPEAT_PARAMS.each do |attribute|
        @event.instance_variable_set :@attribute, nil
      end
    end

    def is_overlap?
      overlap_time_handler = OverlapTimeHandler.new @event
      @is_overlap = overlap_time_handler.valid?
    end
  end
end
