class ChangeTypeInSystemMessage < ActiveRecord::Migration
  def change
    rename_column :system_messages, :type, :message_type
  end
end
