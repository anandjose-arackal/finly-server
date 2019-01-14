class CreateVirtualBankAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :virtual_bank_accounts do |t|
      t.string :account_number
      t.string :ifsc
      t.text :description
      t.references :parent, polymorphic: true
      t.references :company

      t.timestamps null: false
    end
  end
end
