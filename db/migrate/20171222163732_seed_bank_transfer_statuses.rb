class SeedBankTransferStatuses < ActiveRecord::Migration
  def change
    BankTransferStatus.seed_data
    PaymentStatus.seed_data
  end
end
