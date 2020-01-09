class AddCategoryIdToBbpsBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :category_id, :integer, references: "Category", foreign_key: true, index: true
  end
end
