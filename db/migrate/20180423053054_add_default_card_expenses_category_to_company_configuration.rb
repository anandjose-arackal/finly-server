class AddDefaultCardExpensesCategoryToCompanyConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :company_configurations, :default_card_expense_category_id, :integer, references: "Category", foreign_key: true, index: true
  end
end
