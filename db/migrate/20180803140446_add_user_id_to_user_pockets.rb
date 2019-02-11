class AddUserIdToUserPockets < ActiveRecord::Migration[4.2]
  def change
    add_column :user_pockets, :user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
