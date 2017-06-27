module Responsable
  module Event
    def response_create_success service, format
      format.html{redirect_to root_path, flash: {success: t("events.flashs.created")}}
      format.json do
        render json: service.event, serializer: EventSerializer, status: :ok
      end
    end

    def response_create_fail service, format
      if (@is_overlap = service.is_overlap)
        format.html{redirect_back fallback_location: root_path, flash: {error: t("events.flashs.overlap")}}
      else
        format.html{render :new}
      end
      format.json do
        render json: {is_overlap: @is_overlap, is_errors: service.event.errors.any?}
      end
    end

    def response_update_success service, format
      format.html{redirect_to root_path, flash: {success: t("events.flashs.updated")}}
      format.json do
        render json: service.event, serializer: EventSerializer, status: :ok
      end
    end

    def response_update_fail service, format
      if (@is_overlap = service.is_overlap)
        format.html do
          flash.now[:danger] = t("events.flashs.overlap")
          render :edit
        end
        format.json{render json: {is_overlap: @is_overlap}, status: 422}
      else
        format.html{redirect_to :back, flash: {danger: t("events.flashs.not_updated")}}
        format.json{render json: {error: "Error"}, status: 422}
      end
    end

    def response_destroy service, format
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
