class SeedBankAccountProviderData < ActiveRecord::Migration[5.2]
  def change
    BankAccountProvider.seed_data
  end
end
