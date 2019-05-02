class AddUserIdToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :user_id, :integer, references: "User", foreign_key: true
    add_index :items, :user_id
  end
end
