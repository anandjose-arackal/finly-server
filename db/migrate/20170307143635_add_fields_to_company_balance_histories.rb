class AddFieldsToCompanyBalanceHistories < ActiveRecord::Migration[4.2]
  def change
    add_column :company_balance_histories, :cash_on_hand_load_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :company_balance_histories, :cash_on_hand_withdrawal_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :company_balance_histories, :cash_on_hand_balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
