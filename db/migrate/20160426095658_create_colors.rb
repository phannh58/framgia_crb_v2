class CreateColors < ActiveRecord::Migration[5.0]
  def change
    create_table :colors do |t|
      t.string :title
      t.string :color_hex

      t.timestamps null: false
    end
  end
end
