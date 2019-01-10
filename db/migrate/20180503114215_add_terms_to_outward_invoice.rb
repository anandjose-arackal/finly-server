class AddTermsToOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :terms, :text
  end
end
