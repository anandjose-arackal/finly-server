class CreatePaymentTrails < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_trails do |t|
      t.date :date
      t.integer :initiating_account_id, references: "User", foreign_key: true, index: true
      t.integer :receiving_account_id, references: "User", foreign_key: true, index: true
      t.string :initiating_account_type
      t.string :receiving_account_type
      t.integer :initiating_account_pre_balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :initiating_account_post_balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :receiving_account_pre_balance_id, references: "Amount", foreign_key: true, index: true
      t.integer :receiving_account_post_balance_id, references: "Amount", foreign_key: true, index: true
      t.references :payments
      t.references :payment_status

      t.timestamps null: false
    end
  end
end
