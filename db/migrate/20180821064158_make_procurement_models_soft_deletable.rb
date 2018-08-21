class MakeProcurementModelsSoftDeletable < ActiveRecord::Migration
  def change
    add_column :inventory_line_items, :is_deleted, :boolean, default: false, null: false
    add_column :tax_rates, :is_deleted, :boolean, default: false, null: false
    add_column :procurements, :is_deleted, :boolean, default: false, null: false
    add_column :purchase_orders, :is_deleted, :boolean, default: false, null: false
    add_column :purchase_order_items, :is_deleted, :boolean, default: false, null: false
    add_column :bill_of_supplies, :is_deleted, :boolean, default: false, null: false
    add_column :procurement_comments, :is_deleted, :boolean, default: false, null: false
    add_column :delivery_challans, :is_deleted, :boolean, default: false, null: false
    add_column :e_way_bills, :is_deleted, :boolean, default: false, null: false
    add_column :inward_documents, :is_deleted, :boolean, default: false, null: false
    add_column :inward_document_items, :is_deleted, :boolean, default: false, null: false
    add_column :branch_locations, :is_deleted, :boolean, default: false, null: false
    add_column :departments, :is_deleted, :boolean, default: false, null: false
    add_column :procurement_terms, :is_deleted, :boolean, default: false, null: false
    add_column :payment_terms, :is_deleted, :boolean, default: false, null: false
  end
end
