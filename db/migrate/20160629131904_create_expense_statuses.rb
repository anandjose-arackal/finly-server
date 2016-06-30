class CreateExpenseStatuses < ActiveRecord::Migration
  def change
    create_table :expense_statuses do |t|
      t.string :name
      t.integer :order

      t.timestamps null: false
    end
  end
end
