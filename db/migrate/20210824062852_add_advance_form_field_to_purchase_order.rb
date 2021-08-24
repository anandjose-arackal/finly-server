class AddAdvanceFormFieldToPurchaseOrder < ActiveRecord::Migration[6.0]
  def change
    # advance_amount_required
            # requested_advance_amount_id
    # advance_tds_slab_id
            # advance_tds_amount_id
            # advance_amount_id
    # advance_amount_status_id

    add_column :purchase_orders, :po_requested_advance_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :po_advance_tds_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :po_advance_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :reporting_po_requested_advance_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :reporting_po_advance_tds_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :purchase_orders, :reporting_po_advance_amount, :decimal, precision: 20, scale: 10, default: 0
    
    add_column :purchase_orders, :po_advance_tds_percentage, :decimal, precision: 20, scale: 10, default: 0

  end
end
