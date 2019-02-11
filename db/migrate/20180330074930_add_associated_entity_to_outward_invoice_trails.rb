class AddAssociatedEntityToOutwardInvoiceTrails < ActiveRecord::Migration[4.2]
  def change
    add_reference :outward_invoice_trails, :associated_entity, polymorphic: true, index: {name: 'index_outward_inv_trail_on_assoc_entty_type_and_assoc_entity_id'}
    add_reference :outward_invoice_trails, :associated_transaction, polymorphic: true, index: {name: 'index_outward_inv_trail_on_assoc_tranx_type_and_assoc_tranx_id'}
    remove_reference :outward_invoice_trails, :customer_account_transaction, index: true, foreign_key: true
  end
end
