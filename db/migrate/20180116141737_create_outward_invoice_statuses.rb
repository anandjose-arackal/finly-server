class CreateOutwardInvoiceStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :outward_invoice_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
