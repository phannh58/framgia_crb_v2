module Events
  class CreateService
    include MakeActivity
    attr_accessor :is_overlap, :event

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
      %i(repeat_type repeat_every start_repeat end_repeat).each do |attribute|
        @event[attribute.to_sym] = nil
      end
      @event.repeat_ons_attributes = []
    end

    def is_overlap?
      overlap_time_handler = OverlapTimeHandler.new @event
      @is_overlap = overlap_time_handler.valid?
    end
  end
end
