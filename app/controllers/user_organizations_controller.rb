class UserOrganizationsController < ApplicationController
  load_and_authorize_resource

  def create
    user_ids = params[:user_ids]
    org_id = params[:user_organization][:organization_id]
    user_org_params = {user_id: user_ids, organization_id: org_id}
    @user_organization = UserOrganization.create user_org_params
    redirect_to :back, notice: t(".invited")
  end

  def update
    if @user_organization.update_attributes status: params[:commit]
      redirect_to organizations_path, notice: t(".updated", status: params[:commit])
    else
      redirect_to organizations_path, notice: t(".failed")
    end
  end

  private

  def user_organization_params
    params.require(:user_organization).permit UserOrganization::ATTRIBUTE_PARAMS
  end
end
