class CreateItemExpenseTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :item_expense_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
