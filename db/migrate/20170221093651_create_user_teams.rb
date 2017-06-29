class CreateUserTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :user_teams do |t|
      t.references :user, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true
      t.integer :role

      t.timestamps null: false
    end
  end
end
