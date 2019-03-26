class SeedBankTransferStatusModel < ActiveRecord::Migration[5.2]
  def change
    BankTransferStatus.seed_data
  end
end
