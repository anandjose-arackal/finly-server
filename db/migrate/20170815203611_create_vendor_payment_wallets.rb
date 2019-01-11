class CreateVendorPaymentWallets < ActiveRecord::Migration[4.2]
  def change
    create_table :vendor_payment_wallets do |t|
      t.integer :balance_id, references: "Amount", foreign_key: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
