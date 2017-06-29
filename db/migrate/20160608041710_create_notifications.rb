class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string :notification_type

      t.timestamps null: false
    end
  end
end
