class AddCardAtmWithdrawalToCompanyBalances < ActiveRecord::Migration
  def change
    rename_column :company_balance_histories, :card_spend_id, :card_expenses_id
    add_column :company_balance_histories, :card_atm_withdrawal_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
