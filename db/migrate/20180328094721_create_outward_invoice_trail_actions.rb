class CreateOutwardInvoiceTrailActions < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoice_trail_actions do |t|
      t.string :name
    end
  end
end
