class AddChangedPasswordToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :changed_password, :boolean, default: true
  end
end
