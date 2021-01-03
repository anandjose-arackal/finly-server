class AddIndexToInvoicesOnControllingLevelId < ActiveRecord::Migration[6.0]
  def change
    add_index :invoices, [:company_id, :controlling_level_id,:deleted_at], name: "index_invoice_ct_lvl_cmpny_id"
  end
end
