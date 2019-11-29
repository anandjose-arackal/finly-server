class CreateOlapCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_categories do |t|
      t.olap_references
      t.integer :company_id, index: true
      t.string :name, index: true
      t.string :gl_code, index: true
      t.boolean :active, index: true
      t.boolean :expense_management, index: true
      t.boolean :vendor_payments, index: true
      t.boolean :outward_invoices, index: true
      t.boolean :inward_invoice_line_items, index: true
      t.string :ancestry, index: true
      t.boolean :outward_invoice_line_items, index: true
      t.string :category_code, index: true
      t.boolean :gst_applicable, index: true
      t.boolean :tds_applicable, index: true

      t.timestamps index: true
    end
  end
end
