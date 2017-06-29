class DeviseCreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :display_name
      t.string :email,              null: false, default: ""
      t.string :avatar
      t.string :chatwork_id

      t.string :encrypted_password, null: false, default: ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string :token
      t.string :uid
      t.string :provider
      t.string :expires_at
      t.string :refresh_token
      t.boolean :email_require, default: false
      t.string :google_oauth_token

      t.timestamps null: false
    end

    add_index :users, :email,               unique: true
    add_index :users, :name,                unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
