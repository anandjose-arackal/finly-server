class AddDelegateUserIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_delegate_id, :integer, references: "User", foreign_key: true, index: true
  end
end
