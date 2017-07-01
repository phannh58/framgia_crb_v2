class SearchUserService
  def initialize params
    @params = params
  end

  def perform
    return [] if @params[:q].blank?

    org = Organization.find_by slug: @params[:org_slug]
    return [] if org.nil?

    User.select("users.*, user_organizations.status as status")
        .joins("LEFT JOIN user_organizations ON user_organizations.user_id = users.id AND user_organizations.organization_id = #{org.id}")
        .search_name_or_email(@params[:q])
  end
end
