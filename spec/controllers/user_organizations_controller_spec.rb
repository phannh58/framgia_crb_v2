require "rails_helper"
require "devise"

RSpec.describe UserOrganizationsController, type: :controller do
  let(:user){FactoryGirl.create :user}
  let(:organization){FactoryGirl.create :organization, creator_id: user.id}
  let(:user_organization) do
    FactoryGirl.create :user_organization,
      user: user,
      organization: organization
  end

  before do
    sign_in user
    request.env["HTTP_REFERER"] = root_url
  end

  describe "POST #create" do
    # it "create sucess" do
    #   expect do
    #     post :create, params: {
    #       user_ids: user.id,
    #       user_organization: {organization_id: organization.id}
    #     }
    #     expect(response).to redirect_to(fallback_location: root_path)
    #     expect(controller).to set_flash[:notice].to(I18n.t(
    #       "user_organizations.create.invited"))
    #   end.to change(UserOrganization, :count).by 1
    # end
  end

  describe "PATCH #update" do
    it "update success" do
      patch :update, params: {
        id: user_organization.id, commit: :accept
      }
      expect(response).to redirect_to action: :index, controller: :organizations
      expect(controller).to set_flash[:notice].to(I18n.t(
        "user_organizations.update.updated", status: :accept))
    end
    it "update failed" do
      allow(UserOrganization).to receive(:find).with(user_organization.id.to_s)
        .and_return(user_organization)
      allow(user_organization).to receive(:update_attributes).and_return(false)
      patch :update, params: {id: user_organization.id, commit: :accept}
      expect(controller).to set_flash[:notice].to(I18n.t(
        "user_organizations.update.failed"))
      expect(response).to redirect_to action: :index, controller: :organizations
    end
  end
end
