class OrganizationPresenter
  include ActiveModel::Validations

  attr_accessor :organization

  validates :organization, presence: true

  def initialize organization
    @organization = organization
    calendars
  end

  def workspaces
    @workspaces ||= @organization.workspaces
  end

  def members
    @members ||= User.accepted_invite @organization.id
  end

  def workspace_calendars
    if @calendars["Workspace"].nil?
      return @workspace_calendars = NullCalendar.workspace_calendars
    end
    @workspace_calendars ||= @calendars["Workspace"].group_by(&:owner)
  end

  def direct_calendars
    if @calendars["Organization"].nil?
      return @direct_calendars = NullCalendar.direct_calendars
    end
    @direct_calendars ||= @calendars["Organization"]
  end

  def activities
    @activities = PublicActivity::Activity.order(created_at: :desc)
                                          .where owner_type: User.name,
                                                 recipient_type: Organization.name,
                                                 recipient_id: @organization.id
    @activities.map{|activity| ActivityPresenter.new activity}
  end

  private

  def calendars
    @calendars ||= Calendar.of_org(@organization).group_by(&:owner_type)
  end
end
