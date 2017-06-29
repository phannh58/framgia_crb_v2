class CreateUserCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :user_calendars do |t|
      t.references :user
      t.references :calendar
      t.references :permission
      t.references :color
      t.boolean :is_checked, default: true

      t.timestamps null: false
    end
    add_index :user_calendars, [:user_id, :calendar_id], unique: true
  end
end
