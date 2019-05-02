class AddIndexToSystemMessages < ActiveRecord::Migration[5.2]
  def change
    add_index :system_messages, [ :messagable_type, :messagable_id]
    add_index :system_messages, :message_type
    models = ApplicationRecord.descendants
    models.each do |model|
      next unless model <= SoftDeletable
      next if ActiveRecord::Base.connection.index_exists?(model.table_name, :deleted_at)
      add_index model.table_name, :deleted_at
    end
    add_index :receipts, :created_at
    add_index :receipts, :parent_id
  end
end
