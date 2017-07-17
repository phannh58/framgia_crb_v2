# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170717151711) do

  create_table "activities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "trackable_type"
    t.integer  "trackable_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "key"
    t.text     "parameters",     limit: 65535
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id", using: :btree
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id", using: :btree
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id", using: :btree
  end

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  end

  create_table "attendee_group_details", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "attendee_id"
    t.integer  "group_attendee_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["attendee_id"], name: "index_attendee_group_details_on_attendee_id", using: :btree
    t.index ["group_attendee_id"], name: "index_attendee_group_details_on_group_attendee_id", using: :btree
  end

  create_table "attendees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "email"
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_attendees_on_email", using: :btree
    t.index ["user_id"], name: "index_attendees_on_user_id", using: :btree
  end

  create_table "calendars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "creator_id"
    t.integer  "workspace_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name",                                            null: false
    t.string   "address"
    t.string   "google_calendar_id"
    t.string   "description"
    t.integer  "number_of_seats"
    t.integer  "color_id",                        default: 10
    t.integer  "status",                          default: 0
    t.boolean  "is_default",                      default: false
    t.boolean  "is_auto_push_to_google_calendar", default: false
    t.boolean  "is_allow_overlap",                default: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.index ["address"], name: "index_calendars_on_address", unique: true, using: :btree
    t.index ["color_id"], name: "index_calendars_on_color_id", using: :btree
    t.index ["creator_id"], name: "index_calendars_on_creator_id", using: :btree
    t.index ["name"], name: "index_calendars_on_name", using: :btree
    t.index ["owner_id", "owner_type"], name: "index_calendars_on_owner_id_and_owner_type", using: :btree
    t.index ["workspace_id"], name: "index_calendars_on_workspace_id", using: :btree
  end

  create_table "colors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.string   "color_hex"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "days_of_weeks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "priority",                 default: 0, null: false
    t.integer  "attempts",                 default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "event_attendees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "event_id"
    t.integer  "attendee_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["attendee_id"], name: "index_event_attendees_on_attendee_id", using: :btree
    t.index ["event_id"], name: "index_event_attendees_on_event_id", using: :btree
  end

  create_table "event_teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "event_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_teams_on_event_id", using: :btree
    t.index ["team_id"], name: "index_event_teams_on_team_id", using: :btree
  end

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.text     "description",        limit: 65535
    t.boolean  "all_day",                          default: false
    t.integer  "repeat_type"
    t.integer  "repeat_every"
    t.integer  "user_id"
    t.integer  "calendar_id"
    t.datetime "start_date"
    t.datetime "finish_date"
    t.datetime "start_repeat"
    t.datetime "end_repeat"
    t.datetime "exception_time"
    t.integer  "exception_type"
    t.integer  "old_exception_type"
    t.integer  "parent_id"
    t.string   "google_event_id"
    t.string   "google_calendar_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.datetime "deleted_at"
    t.index ["calendar_id"], name: "index_events_on_calendar_id", using: :btree
    t.index ["deleted_at"], name: "index_events_on_deleted_at", using: :btree
    t.index ["google_calendar_id"], name: "index_events_on_google_calendar_id", using: :btree
    t.index ["google_event_id"], name: "index_events_on_google_event_id", using: :btree
    t.index ["parent_id"], name: "index_events_on_parent_id", using: :btree
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, length: { slug: 70, scope: 70 }, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", length: { slug: 140 }, using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "group_attendees", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notification_events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "event_id"
    t.integer  "notification_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["event_id"], name: "index_notification_events_on_event_id", using: :btree
    t.index ["notification_id"], name: "index_notification_events_on_notification_id", using: :btree
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "notification_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "organizations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "display_name"
    t.integer  "creator_id"
    t.string   "logo"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "slug"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree
  end

  create_table "permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.integer  "permission_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["permission_type"], name: "index_permissions_on_permission_type", unique: true, using: :btree
  end

  create_table "repeat_ons", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "event_id"
    t.integer  "days_of_week_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["days_of_week_id"], name: "index_repeat_ons_on_days_of_week_id", using: :btree
    t.index ["event_id"], name: "index_repeat_ons_on_event_id", using: :btree
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "timezone_name"
    t.string   "country"
    t.string   "default_view",  default: "scheduler", null: false
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["owner_id", "owner_type"], name: "index_settings_on_owner_id_and_owner_type", using: :btree
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["organization_id"], name: "index_teams_on_organization_id", using: :btree
  end

  create_table "user_calendars", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "calendar_id"
    t.integer  "permission_id"
    t.integer  "color_id"
    t.boolean  "is_checked",    default: true
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["calendar_id"], name: "index_user_calendars_on_calendar_id", using: :btree
    t.index ["color_id"], name: "index_user_calendars_on_color_id", using: :btree
    t.index ["permission_id"], name: "index_user_calendars_on_permission_id", using: :btree
    t.index ["user_id", "calendar_id"], name: "index_user_calendars_on_user_id_and_calendar_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_user_calendars_on_user_id", using: :btree
  end

  create_table "user_organizations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "status",          default: 0
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["user_id", "organization_id"], name: "index_user_organizations_on_user_id_and_organization_id", unique: true, using: :btree
  end

  create_table "user_teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.integer  "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_user_teams_on_team_id", using: :btree
    t.index ["user_id"], name: "index_user_teams_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                   null: false
    t.string   "display_name"
    t.string   "email",                  default: "",    null: false
    t.string   "avatar"
    t.string   "chatwork_id"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "token"
    t.string   "uid"
    t.string   "provider"
    t.string   "expires_at"
    t.string   "refresh_token"
    t.boolean  "email_require",          default: false
    t.string   "google_oauth_token"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "auth_token",             default: ""
    t.string   "slug"
    t.string   "cable_token"
    t.boolean  "changed_password",       default: true
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["slug"], name: "index_users_on_slug", unique: true, using: :btree
  end

  create_table "workspaces", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "address"
    t.string   "logo"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["organization_id"], name: "index_workspaces_on_organization_id", using: :btree
  end

  add_foreign_key "attendee_group_details", "attendees"
  add_foreign_key "attendee_group_details", "group_attendees"
  add_foreign_key "notification_events", "events"
  add_foreign_key "notification_events", "notifications"
  add_foreign_key "user_teams", "teams"
  add_foreign_key "user_teams", "users"
end
