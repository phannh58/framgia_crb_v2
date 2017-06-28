class AddUserIdToPermission < ActiveRecord::Migration[5.0]
  def change
    add_reference :permissions, :user, foreign_key: true
  end
end
