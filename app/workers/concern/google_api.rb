module GoogleApi
  def self.included klass
    klass.extend ModuleMethods
  end

  module ModuleMethods
    require "google/apis/calendar_v3"
    Calendar = Google::Apis::CalendarV3

    def initialize_googleapi_client
      @client = Calendar::CalendarService.new
      @client.client_options.application_name = I18n.t("events.framgia_crb_system")
      @client.client_options.application_version = "1.0.0"
      @client.authorization = signet_oauth
      @client.authorization.fetch_access_token!
      @client
    end

    def g_event_data event
      time_zone = CalendarPresenter.new(event.owner).tzinfo_name

      Google::Apis::CalendarV3::Event.new({
        summary: event.calendar_name + ": " + event.title,
        location: event.calendar_name,
        description: event.description,
        start: {
          date_time: event.start_date.strftime(I18n.t("events.time.formats.datetime_ft_t_z")),
          time_zone: time_zone
        },
        end: {
          date_time: event.finish_date.strftime(I18n.t("events.time.formats.datetime_ft_t_z")),
          time_zone: time_zone
        },
        attendees: event.attendees.map{|attendee| {email: attendee.attendee_email}}
      })
    end

    private

    def signet_oauth
      require "google/api_client/auth/key_utils"
      require "signet/oauth_2/client"

      keypath = Rails.root.join("config", "client.p12").to_s
      key = Google::APIClient::KeyUtils.load_from_pkcs12(keypath, "notasecret")

      Signet::OAuth2::Client.new(
        token_credential_uri: "https://accounts.google.com/o/oauth2/token",
        audience: "https://accounts.google.com/o/oauth2/token",
        scope: "https://www.googleapis.com/auth/calendar",
        issuer: "framgia-crb-system@framgia-crb-system.iam.gserviceaccount.com",
        signing_key: key
      )
    end
  end
end
