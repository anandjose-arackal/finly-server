class AddErpSyncStatusToInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :erp_sync_statuses do |t|
      t.string :name, index: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
    ErpSyncStatus.seed_data
    add_column :invoices, :erp_sync_status_id, :integer, references: 'erp_sync_statuses'
    add_column :invoices, :erp_sync_message, :text, limit: 4294967295
    add_column :invoices, :erp_sync_id, :string
  end
end
