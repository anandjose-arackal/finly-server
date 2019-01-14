class AddIsDeletedToSystemMessages < ActiveRecord::Migration[4.2]
  def change
    add_column :system_messages, :is_deleted, :boolean, default: false
  end
end
