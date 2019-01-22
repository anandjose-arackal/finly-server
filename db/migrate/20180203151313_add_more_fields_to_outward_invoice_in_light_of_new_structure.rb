class AddMoreFieldsToOutwardInvoiceInLightOfNewStructure < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :billing_address, :text
    add_column :outward_invoices, :shipping_address, :text
    add_column :outward_invoices, :email, :string
    add_column :outward_invoices, :mobile_number, :string

    # removing unnecessary columns from the outward invoice model
    remove_column :outward_invoices, :billing_address_id, :integer
    remove_column :outward_invoices, :shipping_address_id, :integer
    remove_column :outward_invoices, :tax, :decimal, precision: 10, scale: 5
    remove_column :outward_invoices, :discount, :decimal, precision: 10, scale: 5
    remove_column :outward_invoices, :tds_amount_id, :integer
    remove_column :outward_invoices, :category_id, :integer
  end
end
