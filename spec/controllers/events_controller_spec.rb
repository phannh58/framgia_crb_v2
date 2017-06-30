require "rails_helper"
require "devise"

RSpec.describe EventsController, type: :controller do
  before do
    Fabricate :permission, title: I18n.t("permissions.permission_1"), permission_type: 0
    Fabricate :permission, title: I18n.t("permissions.permission_2"), permission_type: 1
    Fabricate :permission, title: I18n.t("permissions.permission_3"), permission_type: 2
    Fabricate :permission, title: I18n.t("permissions.permission_4"), permission_type: 3
  end

  let!(:user){FactoryGirl.create :user}
  let!(:calendar) do
    FactoryGirl.create :calendar,
      owner: user,
      creator: user,
      status: :share_public
  end
  let!(:event) do
    FactoryGirl.create :event,
      calendar: calendar,
      start_date: Time.now - 2.hours,
      finish_date: Time.now - 1.hours
  end
  before do
    sign_in user
  end
  describe "GET #index" do
    before{get :index, format: :json}
    it "have status 200" do
      expect(response).to have_http_status(200)
    end
  end
  describe "GET #shows" do
    context "request format html" do
      before{get :show, params: {id: event.id}}
      it "have status 200" do
        expect(response).to have_http_status(200)
      end
      it "render show template" do
        expect(response).to render_template(:show)
      end
    end
    context "request format js" do
    end
  end
  describe "POST #create" do
    context "request format html" do
      it "create success" do
        expect do
          post :create, params: {event: FactoryGirl.attributes_for(:event, calendar_id: calendar.id)}
          expect(controller).to set_flash[:success].to(I18n.t "events.flashs.created")
          expect(response).to have_http_status(302)
        end.to change(Event, :count).by 1
      end
      it "create failed when overlap" do
        FactoryGirl.create :event, calendar: calendar, start_date: Time.now, finish_date: Time.now + 2.hours

        expect do
          request.env["HTTP_REFERER"] = "/"
          post :create, params: {event: {title: "New event", calendar_id: calendar.id, start_date: Time.now,
            finish_date: Time.now + 1.hours}}
          expect(controller).to set_flash[:error].to(I18n.t "events.flashs.overlap")
          expect(response).to have_http_status(302)
        end.to change(Event, :count).by 0
      end
    end
    context "request format js" do
      it "create success" do
        expect do
          post :create, params: {event: {title: "new event", start_date: Time.now,
            finish_date: Time.now + 1.hours, calendar_id: calendar.id}}, format: :json
          expect(response.header["Content-Type"]).to include "application/json"
          expect(JSON.parse(response.body)["title"]).to eq("new event")
          expect(JSON.parse(response.body)["calendar_id"]).to eq(calendar.id)
          expect(response).to have_http_status(200)
        end.to change(Event, :count).by 1
      end
      it "create failed" do
        FactoryGirl.create :event, calendar: calendar, start_date: Time.now, finish_date: Time.now + 2.hours

        expect do
          request.env["HTTP_REFERER"] = "/"
          post :create, params: {event: {title: "New event", calendar_id: calendar.id, start_date: Time.now,
            finish_date: Time.now + 1.hours}}, format: :json
          expect(JSON.parse(response.body)["is_overlap"]).to eq(true)
        end.to change(Event, :count).by 0
      end
    end
  end
  describe "GET #new" do
    before{get :new}
    it "render new template" do
      expect(response).to render_template(:new)
    end
    it "have status 200" do
      expect(response).to have_http_status(200)
    end
  end
  describe "GET #edit" do
    before{get :edit, params: {id: event.id, event: {title: "new name"}}}
    it "render edit template" do
      expect(response).to render_template(:edit)
    end
    it "have status 200" do
      expect(response).to have_http_status(200)
    end
  end
  describe "PATCH #update" do
    let!(:other_event){FactoryGirl.create :event, calendar: calendar,
      start_date: Time.now, finish_date: Time.now + 30.minutes, repeat_type: :daily,
      repeat_every: 1, start_repeat: Time.now, end_repeat: Time.now + 10.days}
    context "request format html" do
      it "update success" do
        patch :update, params: {id: event.id, event: {title: "new title"}}
        expect(controller).to set_flash[:success].to(I18n.t "events.flashs.updated")
        expect(response).to have_http_status(302)
      end
      it "update failed" do
        patch :update, params: {id: other_event.id, event: {start_date: event.start_date,
          finish_date: event.start_date + 30.minutes}}
        expect(response).to render_template(:edit)
      end
    end
    context "request format js" do
      it "update success" do
        patch :update, params: {id: event.id, event: {title: "new title"}}, format: :json
        expect(response).to have_http_status(200)
        expect(response.header["Content-Type"]).to include "application/json"
        expect(JSON.parse(response.body)["title"]).to eq("new title")
      end
      it "update failed" do
        patch :update, params: {id: other_event.id, event: {start_date: event.start_date,
          finish_date: event.start_date + 30.minutes}}, format: :json
        expect(response).to have_http_status(422)
      end
    end
  end
  describe "DELETE #destroy" do
    let!(:other_event){FactoryGirl.create :event, calendar: calendar,
        start_date: Time.now, finish_date: Time.now + 30.minutes, repeat_type: :daily,
        repeat_every: 1, start_repeat: Time.now, end_repeat: Time.now + 10.days}

    context "request format html" do
      it "destroy sucess" do
        expect do
          delete :destroy, params: {id: other_event.id, exception_type: :delete_all}
          expect(controller).to set_flash[:success].to(I18n.t "events.flashs.deleted")
          expect(response).to have_http_status(302)
        end.to change(Event, :count).by -1
      end
      it "destroy failed" do
        expect do
          delete :destroy, params: {id: other_event.id, exception_type: :delete_all_follow,
            exception_time: Time.now + 1.days}
          expect(controller).to set_flash[:danger].to(I18n.t "events.flashs.not_deleted")
          expect(response).to have_http_status(302)
        end.to change(Event, :count).by 0
      end
    end
    context "request format js" do
      it "destroy sucess" do
        expect do
          delete :destroy, params: {id: other_event.id, exception_type: :delete_all}, format: :json
          expect(response).to have_http_status(200)
          expect(response.header["Content-Type"]).to include "application/json"
          expect(JSON.parse(response.body)["message"]).to eq(I18n.t "events.flashs.deleted")
        end.to change(Event, :count).by -1
      end
      it "destroy failed" do
        expect do
          delete :destroy, params: {id: other_event.id, exception_type: :delete_all_follow,
              exception_time: Time.now + 1.days}, format: :json
          expect(JSON.parse(response.body)["message"]).to eq(I18n.t "events.flashs.not_deleted")
        end.to change(Event, :count).by 0
      end
    end
  end
end
