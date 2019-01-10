class SeedBankTransferStatuses < ActiveRecord::Migration[4.2]
  def change
    BankTransferStatus.seed_data
    PaymentStatus.seed_data
  end
end
