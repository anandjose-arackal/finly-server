class CreateExpenseStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :expense_statuses do |t|
      t.string :name
      t.integer :order

      t.timestamps null: false
    end
  end
end
