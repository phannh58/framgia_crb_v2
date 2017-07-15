module Events
  class ExceptionService
    include MakeActivity
    attr_accessor :event

    EXCEPTION_TYPE = %w(edit_only edit_all edit_all_follow).freeze

    def initialize user, event, params
      @user = user
      @event = event
      @params = params
      @exception_type = event_params[:exception_type] || @event.exception_type
      @exception_time = event_params[:exception_time] || @event.exception_time
    end

    def perform
      return perform_with_exception if @exception_type.in?(EXCEPTION_TYPE)

      begin
        ActiveRecord::Base.transaction do
          make_and_assign_attendees
          @event.assign_attributes event_params
          @event.save!
          make_activity @event.owner, @event, :update
        end
      rescue ActiveRecord::RecordInvalid => exception
        Rails.logger.info('----------------------> ERRORS!!!!')
      end
    end

    private

    def perform_with_exception
      return false if @exception_time.blank?
      return false if Event.find_with_exception @exception_time.to_datetime.utc
      return false if @exception_type.blank?
      send @exception_type
    end

    def edit_only
      Events::Exceptions::EditOnly.new(@user, @event, @params).perform
    end

    def edit_all_follow
      Events::Exceptions::EditAllFollow.new(@user, @event, @params).perform
    end

    def edit_all
      Events::Exceptions::EditAll.new(@event, @params).perform
    end

    def event_params
      @params.require(:event).permit Event::ATTRIBUTES_PARAMS
    end

    def attendee_emails
      return [] if @params[:attendee].blank?
      return @params[:attendee][:emails]
    end

    def make_and_assign_attendees
      users = User.where(email: attendee_emails).select(:email, :id)
      attendees = Attendee.where(email: attendee_emails)
      emails = users.map(&:email) + attendees.map(&:email)

      users.each do |user|
        attendees += [Attendee.find_or_initialize_by(user_id: user.id)]
      end

      attendee_emails.each do |email|
        next if emails.include?(email)
        attendees += [Attendee.new(email: email)]
      end
      @event.attendees = attendees.uniq
    end
  end
end
