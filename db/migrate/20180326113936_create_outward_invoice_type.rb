class CreateOutwardInvoiceType < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoice_types do |t|
      t.string :name
    end


    OutwardInvoiceType.seed_data
  end
end
