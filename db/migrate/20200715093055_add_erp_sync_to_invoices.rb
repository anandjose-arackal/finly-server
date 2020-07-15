class AddErpSyncToInvoices < ActiveRecord::Migration[5.2]
  def change
    ErpSync.setup_migration(Invoice)
  end
end