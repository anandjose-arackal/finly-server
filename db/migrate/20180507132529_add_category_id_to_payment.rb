class AddCategoryIdToPayment < ActiveRecord::Migration[4.2]
  def change
    add_reference :payments, :category, index: true, foreign_key: true
  end
end
