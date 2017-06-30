class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.string :title
      t.integer :permission_type

      t.timestamps null: false
    end
    add_index :permissions, :permission_type, unique: true
  end
end
