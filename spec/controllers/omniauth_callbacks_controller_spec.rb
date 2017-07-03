require "rails_helper"
require "devise"
require "spec_helper"

describe OmniauthCallbacksController, "OmniAuth" do
  describe "POST #facebook" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
    end
    context "login success" do
      it "create user with facebook account" do
        expect do
          post :facebook
          expect(controller).to set_flash[:notice]
            .to(I18n.t("devise.omniauth_callbacks.success", kind: :facebook))
        end.to change(User, :count).by 1
      end
      it "sets a session variable to the OmniAuth auth hash" do
        request.env["omniauth.auth"]["uid"].should == "1234567"
      end
    end
    context "login with facebook failed" do
      it "auth failed" do
        expect do
          post :facebook
          expect(controller).to set_flash[:notice]
            .to(I18n.t("devise.omniauth_callbacks.failed"))
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe "POST #google_oauth2" do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    end
    context "login success" do
      it "create user with google account" do
        expect do
          post :google_oauth2
          expect(controller).to set_flash[:notice]
            .to(I18n.t("devise.omniauth_callbacks.success", kind: :google_oauth2))
        end.to change(User, :count).by 1
      end
      it "sets a session variable to the OmniAuth auth hash" do
        request.env["omniauth.auth"]["uid"].should == "1234567"
      end
    end
    context "login with google failed" do
      it "auth failed" do
        expect do
          post :google_oauth2
          expect(controller).to set_flash[:notice]
            .to(I18n.t("devise.omniauth_callbacks.failed"))
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
