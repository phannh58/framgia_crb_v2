class ActivitiesController < ApplicationController
  def index
    org = Organization.find_by slug: params[:organization_id]
    org_presenter = OrganizationPresenter.new org

    if org.valid?
      @activities = Kaminari.paginate_array(org_presenter.activities)
                            .page(params[:activities])
                            .per Settings.activity.per_page
      render json: {
        content: render_to_string(partial: "shared/activities",
          formats: :html,
          layout: false,
          locals: {activities: @activities})
      }
    else
      render json: {
        content: render_to_string(partial: "shared/errors_messages",
          formats: :html,
          layout: false,
          locals: {object: org})
      }
    end
  end
end
