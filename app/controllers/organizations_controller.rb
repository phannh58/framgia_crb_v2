class OrganizationsController < ApplicationController
  load_and_authorize_resource find_by: :slug
  before_action :load_colors

  def show
    @organization_presenter = OrganizationPresenter.new @organization
    @member_paginate = @organization_presenter.members.page(params[:page])
                                              .per Settings.member.per_page
  end

  def new
    @organization.setting || @organization.build_setting
  end

  def edit
  end

  def create
    @organization = current_user.organizations.build organization_params
    @organization.user_organizations.build user: current_user
    @organization.creator = current_user
    @organization.user_organizations[0].status = 1

    if @organization.save
      flash[:success] = t "organizations.create.created"
      redirect_to @organization
    else
      render :new
    end
  end

  def update
    if @organization.update organization_params
      redirect_to @organization
    else
      render :edit
    end
  end

  def destroy
    if @organization.destroy
      flash[:success] = t ".deleted"
    else
      flash[:notice] = t ".failed"
    end
    redirect_to root_path
  end

  private

  def organization_params
    params.require(:organization).permit Organization::ATTRIBUTE_PARAMS
  end

  def load_colors
    @colors = Color.all
  end
end
