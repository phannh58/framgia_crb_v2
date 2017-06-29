class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :timezone_name
      t.string :country
      t.string :default_view, null: false, default: :scheduler
      t.integer :owner_id
      t.string  :owner_type
      t.timestamps null: false
    end
    add_index :settings, [:owner_id, :owner_type]
  end
end
