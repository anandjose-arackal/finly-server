class CreateInwardInvoiceTypes < ActiveRecord::Migration
  def change
    create_table :inward_invoice_types do |t|
      t.string :name

      t.timestamps null: false
    end

    add_column :invoices, :inward_invoice_type_id, :integer, references: "InwardInvoiceType", foreign_key: true, index: true
  end
end