class CreateBillingAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :billing_accounts do |t|
      t.integer :balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :company_id, references: "Company", foreign_key: true, index: true
      t.boolean :enabled

      t.timestamps
    end
  end
end
