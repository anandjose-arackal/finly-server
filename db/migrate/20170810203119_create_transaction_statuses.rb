class CreateTransactionStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :transaction_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
