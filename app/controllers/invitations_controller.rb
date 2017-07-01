class InvitationsController < ApplicationController
  before_action :load_organization
  before_action :load_invited_user, only: %i(edit)
  before_action :load_user_organization, only: %i(update destroy)

  def show
    @user_org = UserOrganization.find_by user: current_user, organization: @org

    return if @user_org

    flash[:notice] = "Not found"
    redirect_back(fallback_location: root_path)
  end

  def edit
    @user_org = UserOrganization.find_by user: @user, organization: @org
  end

  def create
    @user_org = @org.user_organizations.new user_organization_params

    if @user_org.save
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".danger"
    end
    redirect_to @org
  end

  def update
    if @user_org.update_attributes user_organization_params
      flash[:success] = t ".success"
    else
      flash[:alert] = t ".danger"
    end
    redirect_to root_path
  end

  def destroy
    if @user_org.destroy
      flash[:success] = t ".cancel_success"
    else
      flash[:danger] = t ".danger"
    end
    redirect_to @org
  end

  private

  def user_organization_params
    params.require(:user_organization).permit UserOrganization::ATTRIBUTE_PARAMS
  end

  def load_invited_user
    @user = User.find_by slug: params[:id]

    return if @user
    flash[:notice] = "Not found"
    redirect_back(fallback_location: root_path)
  end

  def load_organization
    @org = Organization.find_by slug: params[:organization_id]

    return if @org
    flash[:notice] = "Not found"
    redirect_back(fallback_location: root_path)
  end

  def load_user_organization
    @user_org = UserOrganization.find_by id: params[:id]

    return if @user_org
    flash[:notice] = "Not found"
    redirect_back(fallback_location: root_path)
  end
end
