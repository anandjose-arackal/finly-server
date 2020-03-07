class AddCategoriesToMoneyRequestItemCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :money_request_item_categories, :category_id, :integer, references: "Category", foreign_key: true, index: true
  end
end
