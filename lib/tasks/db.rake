namespace :db do
  desc "remake database data"
  task remake_data: :environment do

    # if Rails.env.production?
    #   puts "Not running in 'Production' task"
    # else
      %w[db:drop db:create db:migrate].each do |task|
        Rake::Task[task].invoke
      end

      Admin.create email: "admin@crb.framgia.vn", password: 12345678, password_confirmation: 12345678

      Fabrication.clear_definitions
      puts "Create permission"
      Fabricate :permission, title: I18n.t("permissions.permission_1"), permission_type: 0
      Fabricate :permission, title: I18n.t("permissions.permission_2"), permission_type: 1
      Fabricate :permission, title: I18n.t("permissions.permission_3"), permission_type: 2
      Fabricate :permission, title: I18n.t("permissions.permission_4"), permission_type: 3

      Fabricate :notification, notification_type: I18n.t("events.notification.email")
      Fabricate :notification, notification_type: I18n.t("events.notification.chatwork")
      Fabricate :notification, notification_type: I18n.t("events.notification.desktop")

      user_hash = [
        {
          name: "dieunb",
          display_name: "Nguyen Binh Dieu",
          email: "nguyen.binh.dieu@framgia.com"
        },
        {
          name: "tuanca",
          display_name: "Chu Anh Tuan",
          email: "chu.anh.tuan@framgia.com"
        },
        {
          name: "trunghn",
          display_name: "Hoang Nhac Trung",
          email: "hoang.nhac.trung@framgia.com"
        },
        {
          name: "phuongdt",
          display_name: "Doan Thuy Phuong",
          email: "doan.thuy.phuong@framgia.com"
        },
        {
          name: "phuongntd",
          display_name: "Nguyen Thi Duy Phuong",
          email: "nguyen.thi.duy.phuong@framgia.com"
        },
        {
          name: "viemt",
          display_name: "Mai Tuan Viet",
          email: "mai.tuan.viet@framgia.com"
        }
      ]

      puts "Creating Color, User, Calendar, Share calendar, Event"

      Settings.colors.each do |color|
        Fabricate :color, color_hex: color
      end

      Settings.event.repeat_data.each do |date|
        Fabricate :days_of_week, name: date
      end

      user_hash.each do |uhash|
        user = Fabricate :user, name: uhash[:name],
          display_name: uhash[:display_name], email: uhash[:email],
          auth_token: Devise.friendly_token
        user.create_setting country: "VN",
          timezone_name: ActiveSupport::TimeZone.all.sample.name
      end

      tz = ActiveSupport::TimeZone.all.detect{|tz| /Hanoi/.match(tz.name)}

      org = Fabricate :organization, name: "Framgia", creator_id: User.first.id
      org.create_setting country: "VN", timezone_name: tz.name

      [
        {
          workspace_name: "Ha noi Office",
          rooms: ["Dhaka", "Singapore", "Manila", "Phnom penh"],
        },
        {
          workspace_name: "Toong Office",
          rooms: ["Toong 01"]
        },
        {
          workspace_name: "TKC Office",
          rooms: ["TKC 01", "TKC 02"]
        },
        {
          workspace_name: "Da nang Office",
          rooms: ["DN 01", "DN 02"]
        },
        {
          workspace_name: "HCM Office",
          rooms: ["HCM 01", "HCM 02"]
        }
      ].each do |ws_item|
        workspace = Fabricate :workspace, name: ws_item[:workspace_name],
          organization: org

        ws_item[:rooms].each do |room_name|
          Fabricate :calendar, owner: workspace,
            creator_id: User.first.id, name: room_name, color: Color.all.sample
        end
      end

    # end
  end
end
