class AddTermsToOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :terms, :text
  end
end
