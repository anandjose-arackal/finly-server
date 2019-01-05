class AddInvlucesiveOfTaxesForOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :inclusive_of_taxes, :boolean
  end
end
