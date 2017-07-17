class CreateCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :calendars do |t|
      t.integer :creator_id
      t.integer :workspace_id
      t.integer :owner_id
      t.string  :owner_type
      t.string :name, null: false
      t.string :address
      t.string :google_calendar_id
      t.string :description
      t.integer :number_of_seats
      t.references :color, default: 10
      t.integer :status, default: 0
      t.boolean :is_default, default: false
      t.boolean :is_auto_push_to_google_calendar, default: false
      t.boolean :is_allow_overlap, default: false

      t.timestamps null: false
    end

    add_index :calendars, :name
    add_index :calendars, :address,               unique: true
    add_index :calendars, :creator_id
    add_index :calendars, :workspace_id
    add_index :calendars, [:owner_id, :owner_type]
  end
end
