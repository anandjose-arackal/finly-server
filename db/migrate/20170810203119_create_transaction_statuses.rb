class CreateTransactionStatuses < ActiveRecord::Migration
  def change
    create_table :transaction_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
