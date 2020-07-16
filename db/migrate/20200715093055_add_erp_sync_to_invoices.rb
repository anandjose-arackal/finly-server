class AddErpSyncToInvoices < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(Invoice)
  end
end