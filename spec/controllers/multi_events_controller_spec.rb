require "rails_helper"
require "devise"

RSpec.describe MultiEventsController, type: :controller do
  let!(:user){ FactoryGirl.create :user}
  let!(:user1){ FactoryGirl.create :user}
  let!(:calendar){ FactoryGirl.create :calendar, owner: user, creator_id: user.id}
  let!(:calendar1){ FactoryGirl.create :calendar, owner: user1, creator_id: user1.id}

  before do
    sign_in user
    request.env["HTTP_REFERER"] = root_url
  end

  describe "POST #create" do
    it "create success" do
      expect do
        post :create, params: {calendar_ids: [calendar.id, calendar1.id],
          start_date: Time.now + 1.hours, finish_date: Time.now + 2.hours}
        expect(controller).to set_flash[:success].to(I18n.t("events.flashs.created"))
        expect(response).to redirect_to root_path
      end.to change(Event, :count).by 2
    end
    it "failed: object not blank" do
      FactoryGirl.create :event, calendar: calendar, start_date: Time.now, finish_date: Time.now + 2.hours
      expect do
        post :create, params: {calendar_ids: [calendar.id, calendar1.id],
          start_date: Time.now, finish_date: Time.now + 1.hours}
        expect(response).to redirect_to :back
      end.to change(Event, :count).by 0
    end
  end
end
