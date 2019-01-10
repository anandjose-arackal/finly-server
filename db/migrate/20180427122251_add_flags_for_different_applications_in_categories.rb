class AddFlagsForDifferentApplicationsInCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :expense_management, :boolean
    add_column :categories, :vendor_payments, :boolean
    add_column :categories, :outward_invoices, :boolean
    add_column :categories, :invoice_line_items, :boolean
  end
end
