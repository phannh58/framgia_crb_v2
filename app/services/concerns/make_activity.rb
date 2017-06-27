module MakeActivity
  private

  def make_activity user, event, method
    calendar = event.calendar
    return if calendar.nil?
    return if calendar.owner_type == User.name

    if calendar.owner_type == Organization.name
      organization = event.calendar.owner
    elsif calendar.owner_type == Workspace.name
      organization = event.calendar.owner.organization
    end

    event.create_activity method, owner: user, recipient: organization
  end
end
