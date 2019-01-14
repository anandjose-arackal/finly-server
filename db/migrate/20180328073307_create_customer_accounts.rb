class CreateCustomerAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :customer_accounts do |t|
      t.references :customer, index: true, foreign_key: true
      t.integer :balance_id, references: "Amount", foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
