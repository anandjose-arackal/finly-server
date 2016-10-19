class CreateCompanyAccounts < ActiveRecord::Migration
  def change
    create_table :company_accounts do |t|
      t.references :company, index: true, foreign_key: true, null: false
      t.integer :wallet_balance_id, :company, :references => 'amount',
                index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
