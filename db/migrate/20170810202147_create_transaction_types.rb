class CreateTransactionTypes < ActiveRecord::Migration
  def change
    create_table :transaction_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    TransactionType.seed_data
  end
end
