class MoveCategoriesFromPurposeToNewSystem < ActiveRecord::Migration[4.2]
  def change
    # add flag for outwatd invoice items as well to categories
    rename_column :categories, :invoice_line_items, :inward_invoice_line_items
    add_column :categories, :outward_invoice_line_items, :boolean


    Category.all.each do |category|
      purpose_id = category.purpose_id
      case purpose_id
        when Purpose.id_for(:expense_management)
          category.update(expense_management: true)
        when Purpose.id_for(:vendor_payments)
          category.update(vendor_payments: true)
        when Purpose.id_for(:invoice)
          category.update(vendor_payments: true)
        when Purpose.id_for(:invoice_items)
          category.update(inward_invoice_line_items: true)
        when Purpose.id_for(:outward_invoice)
          category.update(outward_invoices: true)
        when Purpose.id_for(:outward_invoice_line_items)
          category.update(outward_invoice_line_items: true)
        else
          # do nothing?
      end
    end
  end
end