class AddWalletBalanceToCompanyBalanceHistories < ActiveRecord::Migration[4.2]
  def change
    add_column :company_balance_histories, :wallet_balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
