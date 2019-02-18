class SuffixProviderInProcurement < ActiveRecord::Migration[5.2]
  def change
    ReviewalLevel.unscoped.where(associated_entity_type: 'PurchaseOrder').update_all(associated_entity_type: 'PurchaseOrderProvider')
    ReviewalLevel.unscoped.where(associated_entity_type: 'Invoice').update_all(associated_entity_type: 'InvoiceProvider')
  end
end
