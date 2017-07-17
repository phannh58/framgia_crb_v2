module Responsable
  module Event
    def response_create_success service
      respond_to do |format|
        format.html{redirect_to root_path, flash: {success: t("events.flashs.created")}}
        format.json do
          render json: service.event, serializer: EventSerializer, status: :ok
        end
      end
    end

    def response_create_fail service
      respond_to do |format|
        format.html{render :new}
        format.json do
          render json: {is_errors: service.event.errors.any?}
        end
      end
    end

    def response_update_success service
      respond_to do |format|
        format.html{redirect_to root_path, flash: {success: t("events.flashs.updated")}}
        format.json do
          render json: service.event, serializer: EventSerializer, status: :ok
        end
      end
    end

    def response_update_fail service
      respond_to do |format|
        format.html{redirect_to :back, flash: {danger: t("events.flashs.not_updated")}}
        format.json{render json: {error: "Error"}, status: 422}
      end
    end

    def response_destroy service
      respond_to do |format|
        if service.perform
          format.html{redirect_to root_path, flash: {success: t("events.flashs.deleted")}}
          format.json{render json: {message: t("events.flashs.deleted")}, status: :ok}
        else
          format.html{redirect_to root_path, flash: {danger: t("events.flashs.not_deleted")}}
          format.json{render json: {message: t("events.flashs.not_deleted")}}
        end
      end
    end
  end
end
