class AddErpSyncStatusToInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :erp_sync_statuses do |t|
      t.string :name, index: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
    ErpSyncStatus.seed_data
  end
end
