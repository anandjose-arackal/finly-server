class AddIndexToPoPrVendorOnControllingLevelId < ActiveRecord::Migration[6.0]
  def change
    add_index :purchase_orders, [:company_id, :controlling_level_id,:deleted_at], name: "index_po_ct_lvl_cmpny_id"
    add_index :purchase_requests, [:company_id, :controlling_level_id,:deleted_at], name: "index_po_ct_lvl_cmpny_id"
    add_index :yes_bank_vendors, [:company_id, :controlling_level_id,:deleted_at], name: "index_vendors_ct_lvl_cmpny_id"
    add_index :bank_payment_requests, [:company_id, :controlling_level_id,:deleted_at], name: "index_bpr_ct_lvl_cmpny_id"
  end
end
