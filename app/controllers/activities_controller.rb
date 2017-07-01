class ActivitiesController < ApplicationController
  before_action :verify_request!
  before_action :load_organization

  def index
    org_presenter = OrganizationPresenter.new @org
    activities = Kaminari.paginate_array(org_presenter.activities)
                         .page(params[:activities])
                         .per Settings.activity.per_page

    render json: {
      content: render_to_string(partial: "shared/activities",
        formats: :html,
        layout: false,
        locals: {activities: activities})
    }
  end

  private

  def load_organization
    @org = Organization.find_by slug: params[:organization_id]

    return if @org

    respond_to do |format|
      format.html{redirect_to root_path, notice: "Not found"}
      format.json{render json: {error: "not found"}, status: 401}
    end
  end

  def verify_request!
    return if request.xhr?
    redirect_to root_path, notice: "Not permission!!!"
  end
end
