class CreateDaysOfWeeks < ActiveRecord::Migration[5.0]
  def change
    create_table :days_of_weeks do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
