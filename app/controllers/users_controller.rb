class UsersController < ApplicationController
  load_and_authorize_resource find_by: :slug, only: %i(show)

  def show
    resource.setting || resource.build_setting
  end

  def search
    @users = SearchUserService.new(params).perform
    render layout: "ajax"
  end
end
