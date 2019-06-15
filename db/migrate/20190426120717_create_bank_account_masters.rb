class CreateBankAccountMasters < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_account_masters do |t|
      t.string :account_number
      t.string :ifsc
      t.string :account_name

      t.timestamps
    end
  end
end
