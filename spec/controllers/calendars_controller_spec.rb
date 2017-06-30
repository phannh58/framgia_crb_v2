require "rails_helper"
require "devise"

RSpec.describe CalendarsController, type: :controller do
  before do
    Fabricate :permission, title: I18n.t("permissions.permission_1"), permission_type: 0
    Fabricate :permission, title: I18n.t("permissions.permission_2"), permission_type: 1
    Fabricate :permission, title: I18n.t("permissions.permission_3"), permission_type: 2
    Fabricate :permission, title: I18n.t("permissions.permission_4"), permission_type: 3
  end

  let!(:user){FactoryGirl.create :user}
  let!(:calendar){FactoryGirl.create :calendar, owner: user, creator_id: user.id}

  describe "GET #index" do
    before{get :index}
    it "have status 200" do
      expect(response).to have_http_status(200)
    end
    it "render index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    before{sign_in user}
    it "create success" do
      expect do
        post :create, params: {owner_type: User.name, owner_id: user.slug, calendar: FactoryGirl.attributes_for(:calendar)}
        expect(controller).to set_flash[:success].to(I18n.t "calendar.success_create")
        expect(response).to redirect_to action: :index
      end.to change(Calendar, :count).by 1
    end
    it "create failed" do
      expect do
        post :create, params: {owner_type: User.name, calendar: FactoryGirl.attributes_for(:calendar)}
        expect(response).to render_template :new
      end.to change(Calendar, :count).by 0
    end
  end

  describe "GET #new" do
    before{sign_in user}
    it "render new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    before{sign_in user}
    it "render edit template" do
      get :edit, params: {id: calendar.id}
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    before{sign_in user}
    it "update success" do
      patch :update, params: {id: calendar.id,
          calendar: FactoryGirl.attributes_for(:calendar)}
      expect(controller).to set_flash[:success].to(I18n.t "calendar.success_update")
      expect(response).to redirect_to action: :index
    end
    it "update failed" do
      allow(Calendar).to receive(:find).with(calendar.id.to_s).and_return(calendar)
      allow(calendar).to receive(:update_attributes).and_return(false)
      patch :update, params: {id: calendar.id, calendar: {name: ""}}
      expect(response).to render_template(:edit)
    end
  end

  describe "DELETE #destroy" do
    it "delete success" do
      sign_in user
      expect do
        delete :destroy, params: {id: calendar.id}
        expect(controller).to set_flash[:success].to(I18n.t "calendars.deleted")
      end.to change(Calendar, :count).by -1
    end
    it "delete failed" do
      sign_in user
      expect do
        allow(Calendar).to receive(:find).with(calendar.id.to_s).and_return(calendar)
        allow(calendar).to receive(:destroy).and_return(false)
        delete :destroy, params: {id: calendar.id}
        expect(Calendar).to have_received(:find)
        expect(calendar).to have_received(:destroy)
        expect(controller).to set_flash[:alert].to(I18n.t "calendars.not_deleted")
      end.to change(Calendar, :count).by 0
    end
  end
end
