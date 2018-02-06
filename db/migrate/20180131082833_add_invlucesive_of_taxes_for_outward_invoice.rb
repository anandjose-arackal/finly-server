class AddInvlucesiveOfTaxesForOutwardInvoice < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :inclusive_of_taxes, :boolean
  end
end
