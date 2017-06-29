class CreateEventTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :event_teams do |t|
      t.references :event
      t.references :team

      t.timestamps null: false
    end
  end
end
