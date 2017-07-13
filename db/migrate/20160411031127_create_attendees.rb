class CreateAttendees < ActiveRecord::Migration[5.0]
  def change
    create_table :attendees do |t|
      t.string :email
      t.integer :user_id
      t.integer :event_id
      t.integer :status

      t.timestamps null: false
    end
    add_index :attendees, :email 
    add_index :attendees, :user_id 
    add_index :attendees, :event_id
  end
end
