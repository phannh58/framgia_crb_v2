class CreateAttendeeGroupDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :attendee_group_details do |t|
      t.references :attendee, foreign_key: true
      t.references :group_attendee, foreign_key: true

      t.timestamps
    end
  end
end
