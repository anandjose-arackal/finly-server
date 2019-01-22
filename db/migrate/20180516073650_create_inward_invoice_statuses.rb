class CreateInwardInvoiceStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :inward_invoice_statuses do |t|
      t.string :name

      t.timestamps null: false
    end

    InwardInvoiceStatus.seed_data
  end
end