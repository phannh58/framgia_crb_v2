class CalendarPresenter
  attr_reader :user, :organization, :object

  def initialize user, organization = nil
    @user = user
    @organization = organization
    @object = existed_org? ? @organization : @user
  end

  def my_calendars
    calendars
  end

  def shared_calendars
    @user.shared_calendars
  end

  def manage_calendars
    @user.manage_calendars
  end

  def calendars_json
    all_calendars = calendars.map(&owner_calendar_block)

    unless existed_org?
      all_calendars += shared_calendars.map(&share_calendar_block)
    end
    all_calendars.to_json
  end

  def default_view
    @object.setting_default_view
  end

  def full_timezone_name
    ["GMT#{timezone.now.strftime('%:z')}", tzinfo_name].join(" ")
  end

  def tzinfo_name
    timezone.tzinfo.name
  end

  def logo_url
    existed_org? ? @organization.logo_url : @user.avatar_url
  end

  def org_obj?
    existed_org?
  end

  private

  def existed_org?
    @existed_org ||= @organization.present?
  end

  def timezone
    @timezone ||= ActiveSupport::TimeZone[@user.setting_timezone_name]
  end

  def calendars
    return Calendar.of_org(@organization) if existed_org?
    Calendar.of_user(@user)
  end

  def owner_calendar_block
    proc do |calendar|
      {
        id: calendar.id,
        name: calendar.name,
        building: calendar.bulding_name,
        is_allow_overlap: calendar.is_allow_overlap
      }
    end
  end

  def share_calendar_block
    proc do |calendar|
      {
        id: calendar.id,
        name: calendar.name,
        building: "Shared Calendar",
        is_allow_overlap: calendar.is_allow_overlap
      }
    end
  end
end
