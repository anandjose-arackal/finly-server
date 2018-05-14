class AddCategoryIdToPayment < ActiveRecord::Migration
  def change
    add_reference :payments, :category, index: true, foreign_key: true
  end
end
