module GoogleApi
  def self.included klass
    klass.extend ModuleMethods
  end

  module ModuleMethods
    def initialize_googleapi_client
      @client = Google::APIClient.new google_config
      @client.authorization = signet_oauth
      @client.authorization.fetch_access_token!
      @client
    end

    def g_event_data event
      attendees = event.attendees.map{|attendee| {email: attendee.attendee_email}}
      attendees = attendees << {email: event.calendar.owner.email}

      {
        summary: event.calendar_name + ": " + event.title,
        location: event.calendar_name,
        description: event.description,
        start: {dateTime: event.start_date.strftime(I18n.t("events.time.formats.datetime_ft_t_z"))},
        end: {dateTime: event.finish_date.strftime(I18n.t("events.time.formats.datetime_ft_t_z"))},
        attendees: attendees
      }
    end

    private

    def signet_oauth
      keypath = Rails.root.join("config", "client.p12").to_s
      key = Google::APIClient::PKCS12.load_key(keypath, "notasecret")

      Signet::OAuth2::Client.new(
        token_credential_uri: "https://accounts.google.com/o/oauth2/token",
        audience: "https://accounts.google.com/o/oauth2/token",
        scope: "https://www.googleapis.com/auth/calendar",
        issuer: "framgia-crb-system@framgia-crb-system.iam.gserviceaccount.com",
        signing_key: key
      )
    end

    def google_config
      {
        application_name: I18n.t("events.framgia_crb_system"),
        application_version: "1.0"
      }
    end
  end
end
