class CreateUserOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_organizations do |t|
      t.integer :status, default: 0
      t.integer :user_id, foreign_key: true
      t.integer :organization_id, foreign_key: true

      t.timestamps null: false
    end
    add_index :user_organizations, [:user_id, :organization_id], unique: true
  end
end
