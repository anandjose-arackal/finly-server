class AddCategoryToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :category_id, :integer, references: "Category", index: true, foreign_key: true
  end
end