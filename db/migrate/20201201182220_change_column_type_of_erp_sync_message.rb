class ChangeColumnTypeOfErpSyncMessage < ActiveRecord::Migration[6.0]
  def change
    change_column :invoices, :erp_sync_message, :text
    change_column :invoices, :erp_sync_reference_id, :text

    change_column :payments, :erp_sync_message, :text
    change_column :payments, :erp_sync_reference_id, :text

    change_column :reports, :erp_sync_message, :text
    change_column :reports, :erp_sync_reference_id, :text

    change_column :users, :erp_sync_message, :text
    change_column :users, :erp_sync_reference_id, :text

    change_column :yes_bank_vendors, :erp_sync_message, :text
    change_column :yes_bank_vendors, :erp_sync_reference_id, :text
  end
end
