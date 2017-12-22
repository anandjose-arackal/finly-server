class SeedBankTransferStatuses < ActiveRecord::Migration
  def change
    BankTransferStatus.seed_data
  end
end
