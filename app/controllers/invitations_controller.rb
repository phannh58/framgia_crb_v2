class InvitationsController < ApplicationController
  before_action :load_organization
  before_action :load_user_org, only: %i(show edit)
  before_action :verify_permission!, only: :show
  before_action :load_invited_user, only: :edit

  def show; end

  def edit; end

  def create
    @user_org = @organization.user_organizations.new user_organization_params

    if @user_org.save
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".danger"
    end
    redirect_to @organization
  end

  def update
    @user_org.update_attributes status: :accept
    redirect_to root_path
  end

  def destroy
    if @user_org.destroy
      flash[:success] = t ".cancel_success"
      redirect_to @organization
    else
      flash[:danger] = t ".danger"
    end
  end

  private

  def user_organization_params
    params.require(:user_organization).permit :user_id
  end

  def verify_permission!
    return if @user_org.waiting?
    redirect_to root_path, notice: t(".no_permission")
  end

  def load_user_org
    @user_org = UserOrganization.find_by user: current_user, organization: @org

    return if @user_org

    flash[:notice] = "Not found"
    redirect_to root_path
  end

  def load_invited_user
    @user = User.find_by slug: params[:id]
  end

  def load_organization
    @org = Organization.find_by slug: params[:organization_id]
  end
end
