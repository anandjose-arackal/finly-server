class CreateBankTransactionTypes < ActiveRecord::Migration
  def change
    create_table :bank_transaction_types do |t|
      t.string :name

      t.timestamps null: false
    end

    BankTransactionType.seed_data
  end
end