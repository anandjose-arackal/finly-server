class AddCategoryToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_reference :expenses, :category, index: true, foreign_key: true
  end
end
