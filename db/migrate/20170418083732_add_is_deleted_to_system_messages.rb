class AddIsDeletedToSystemMessages < ActiveRecord::Migration
  def change
    add_column :system_messages, :is_deleted, :boolean, default: false
  end
end
