class TeamsController < ApplicationController
  load_and_authorize_resource
  before_action :build_a_team_of_a_organization, only: [:create]
  before_action :load_organization_has_teams, only: [:destroy]

  def new
    @team = Team.new
  end

  def show; end

  def create
    if @team.save
      redirect_to organization_path(@organization), notice: t(".created_team")
    else
      render :new
    end
  end

  def update
    if @team.update team_params
      render json: @team
    else
      render :new
    end
  end

  def destroy
    if @team.destroy
      load_organization_has_teams
      render partial: "organizations/organization_teams", locals: {organization: @organization}
    else
      render partial: "shared/errors_messages", locals: {object: @team}
    end
  end

  private

  def team_params
    params.require(:team).permit Team::ATTR_PARAMS
  end

  def build_a_team_of_a_organization
    load_organization_has_teams
    @team = @organization.teams.build team_params
  end

  def load_organization_has_teams
    @organization = Organization.find_by id: params[:organization_id]
  end
end
