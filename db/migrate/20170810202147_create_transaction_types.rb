class CreateTransactionTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :transaction_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    TransactionType.seed_data
  end
end
