class AddMissingIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id,], name: "index_invoice_awaiting_approval_fields" rescue nil
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_2" rescue nil
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id, :created_by_user_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_3" rescue nil
    add_index :invoices, [:deleted_at, :company_id, :created_by_user_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_4" rescue nil
    add_index :invoices, [:deleted_at, :company_id, :policy_id], name: "index_invoice_awaiting_approval_fields_5" rescue nil

    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id, :status_id], name: "index_bpr_fields" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id, :status_id, :owner_id], name: "index_bpr_fields_2" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id], name:
      "index_bpr_fields_3" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :status_id], name: "index_bpr_fields_4" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :owner_id], name: "index_bpr_fields_5" rescue nil

    add_index :payment_orders, [:deleted_at, :payment_purpose_id, :payment_order_status_id], name: "index_bpr_order_fields" rescue nil
    add_index :payment_orders, [:deleted_at, :payment_order_status_id], name: "index_bpr_order_fields_2" rescue nil
    add_index :payment_orders, [:deleted_at, :payment_purpose_id, ], name: "index_bpr_order_fields_3" rescue nil

    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id, :owner_id], name: "index_bpr_awaiting_approval_fields" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id], name: "index_bpr_awaiting_approval_fields_2" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :controlling_level_id, :company_id], name: "index_bpr_awaiting_approval_fields_3" rescue nil
    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id, :owner_id], name: "index_bpr_awaiting_approval_fields_4" rescue nil
  end
end
