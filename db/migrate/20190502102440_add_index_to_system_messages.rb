class AddIndexToSystemMessages < ActiveRecord::Migration[5.2]
  def change
    add_index :system_messages, [:messagable_type, :messagable_id]
    add_index :system_messages, :message_type
    models = ApplicationRecord.descendants
    models.each do |model|
      next unless model <= SoftDeletable
      next if ActiveRecord::Base.connection.index_exists?(model.table_name, :deleted_at)
      add_index model.table_name, :deleted_at
    end
    add_index :receipts, :created_at
    add_index :receipts, :parent_id
    add_index :payments, [ :reference_resource_type, :reference_resource_id], name: 'index_payments_on_reference_resource'
    add_index :payments, :created_at
    add_index :payments, :date

    add_index :bank_payment_requests, :created_at
    add_index :budget_trails, [:entity_type, :entity_id]
    add_index :expenses, :created_at

    add_index :bank_accounts, :created_at
    add_index :procurements, :procurement_type
    add_index :procurement_attachments, [:procurement_document_id, :procurement_document_type], name: "index_procurement_attachments_on_procurement_document"
    add_index :invoices, :controlling_level_id
  end
end
