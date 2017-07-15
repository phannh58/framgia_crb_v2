class CreateEventAttendees < ActiveRecord::Migration[5.0]
  def change
    create_table :event_attendees do |t|
      t.integer :event_id
      t.integer :attendee_id

      t.timestamps null: false
    end
    add_index :event_attendees, :event_id
    add_index :event_attendees, :attendee_id
  end
end
