class FixMessageLengthInErpSyncAttemp < ActiveRecord::Migration[6.0]
  def change
    change_column :erp_sync_attempts, :message, :text
    change_column :erp_sync_attempts, :message, :reference_id
  end
end
