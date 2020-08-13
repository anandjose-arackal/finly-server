class ErpSyncVendorSetup < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(YesBankVendor)
  end
end
