class ChangeCompanyBalanceFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :company_balance_histories, :company_withdrawal_id, :company_withdrawal_to_card_id
    add_column :company_balance_histories, :company_withdrawal_to_wallet_id, :integer, references: "Amount", foreign_key: true, index: true
    rename_column :company_balance_histories, :company_load_id, :company_load_from_card_id
    add_column :company_balance_histories, :company_load_from_wallet_id, :integer, references: "Amount", foreign_key: true, index: true
    rename_column :company_balance_histories, :card_withdrawal_id, :card_withdrawal_to_wallet_id
    add_column :company_balance_histories, :card_withdrawal_to_card_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :company_balance_histories, :card_withdrawal_to_virtual_account_id, :integer, references: "Amount", foreign_key: true, index: true
    rename_column :company_balance_histories, :card_load_id, :card_load_from_wallet_id
    add_column :company_balance_histories, :card_load_from_card_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :company_balance_histories, :card_load_from_virtual_account_id, :integer, references: "Amount", foreign_key: true, index: true
    remove_column :company_balance_histories, :finly_money_withdrawal_id
    add_column :company_balance_histories, :wallet_withdrawal_to_wallet_id, :integer, foreign_key: true
    add_index :company_balance_histories, :wallet_withdrawal_to_wallet_id, name: "index_wal_2_wal_on_company_history"
    add_column :company_balance_histories, :wallet_withdrawal_to_card_id, :integer, references: "Amount", foreign_key: true
    add_index :company_balance_histories, :wallet_withdrawal_to_card_id, name: "index_wal_2_card_on_company_history"
    add_column :company_balance_histories, :wallet_withdrawal_to_virtual_account_id, :integer, references: "Amount", foreign_key: true
    add_index :company_balance_histories, :wallet_withdrawal_to_virtual_account_id, name: "index_wal_2_va_on_company_history"
    rename_column :company_balance_histories, :finly_money_load_id, :wallet_load_from_wallet_id
    add_column :company_balance_histories, :wallet_load_from_card_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :company_balance_histories, :wallet_load_from_virtual_account_id, :integer, references: "Amount", foreign_key: true
    add_index :company_balance_histories, :wallet_load_from_virtual_account_id, name: "index_wal_load_on_company_history"
  end
end
