class AddErpSyncToCreditNotes < ActiveRecord::Migration[6.0]
  def change
    ErpSyncAttempt.setup_migration(CreditNote)
  end
end
