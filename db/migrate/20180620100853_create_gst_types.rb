class CreateGstTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :gst_types do |t|
      t.string :name, index: true

      t.timestamps null: false
    end
    GstType.seed_data
    change_column :expenses, :gst_type_id, :integer, references: 'GstType', index: true, foreign_key: true
    change_column :invoices, :gst_type_id, :integer, references: 'GstType', index: true, foreign_key: true
    change_column :invoice_line_items, :gst_type_id, :integer, references: 'GstType', index: true, foreign_key: true
    change_column :outward_invoices, :gst_type_id, :integer, references: 'GstType', index: true, foreign_key: true
  end
end