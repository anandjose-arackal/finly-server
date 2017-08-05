class AddCompanyIdToQuickbooksCategories < ActiveRecord::Migration
  def change
    add_column :quickbooks_categories, :company_id, :integer, references: "Company", foreign_key: true, index: true

    # add company id to all existing quickbooks configurations
    Category.all.each do |category|
      if category.quickbooks_category.present?
        category.quickbooks_category.update(company_id: category.company_id)
      end
    end
  end
end
