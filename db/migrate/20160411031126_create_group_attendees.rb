class CreateGroupAttendees < ActiveRecord::Migration[5.0]
  def change
    create_table :group_attendees do |t|
      t.string :name
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
