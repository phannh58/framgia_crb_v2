class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :display_name
      t.integer :creator_id
      t.string :logo

      t.timestamps null: false
    end
  end
end
