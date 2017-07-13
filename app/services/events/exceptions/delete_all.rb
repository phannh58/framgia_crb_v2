module Events
  module Exceptions
    class DeleteAll
      def initialize event
        @event = event.parent ? event.parent : event
      end

      def perform
        begin
          ActiveRecord::Base.transaction do
            @event.destroy!
            @event.event_exceptions.each{|event| event.destroy!}
          end
        rescue ActiveRecord::RecordInvalid => exception
          Rails.logger.info('----------------------> ERRORS!!!!')
        end
      end
    end
  end
end
