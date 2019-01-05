class CreateYesBankCompanyAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :yes_bank_company_accounts do |t|
      t.references :company, index: true, foreign_key: true
      t.integer :wallet_balance_id

      t.timestamps null: false
    end
  end
end
