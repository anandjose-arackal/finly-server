class AddDefaultCategoryToDistanceAndTimeExpenseConfig < ActiveRecord::Migration[4.2]
  def change
    add_column :distance_expense_configs, :default_category_id, :integer, references: "Category", index: true, foreign_key: true
    add_column :time_expense_configs, :default_category_id, :integer, references: "Category", index: true, foreign_key: true
  end
end
