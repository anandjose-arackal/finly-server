class ChangeTypeInSystemMessage < ActiveRecord::Migration[4.2]
  def change
    rename_column :system_messages, :type, :message_type
  end
end
