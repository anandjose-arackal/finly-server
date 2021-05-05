class AddEpSyncMessageToCreditNote < ActiveRecord::Migration[6.0]

  def change
      ErpSyncAttempt.setup_migration(CreditNote) rescue nil
  end

end
