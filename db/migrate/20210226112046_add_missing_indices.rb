class AddMissingIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id,], name: "index_invoice_awaiting_approval_fields"
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_2"
    add_index :invoices, [:deleted_at, :invoice_status_id, :policy_id, :controlling_level_id, :company_id, :created_by_user_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_3"
    add_index :invoices, [:deleted_at, :company_id, :created_by_user_id, :invoice_type_id], name: "index_invoice_awaiting_approval_fields_4"
    add_index :invoices, [:deleted_at, :company_id, :policy_id], name: "index_invoice_awaiting_approval_fields_5"
    add_index :invoices, [:company_id, :policy_id], name: "index_invoice_awaiting_approval_fields_6"

    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id, :status_id], name: "index_bpr_fields"
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id, :status_id, :owner_id], name: "index_bpr_fields_2"
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :payment_order_id], name:
      "index_bpr_fields_3"
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :status_id], name: "index_bpr_fields_4"
    add_index :bank_payment_requests, [:deleted_at, :owner_id], name: "index_bpr_fields_5"
    add_index :bank_payment_requests, [:deleted_at, :owner_id, :policy_id, :status_id], name: "index_bpr_fields_6"
    add_index :bank_payment_requests, [:owner_id, :policy_id], name: "index_bpr_fields_7"

    add_index :payment_orders, [:deleted_at, :payment_purpose_id, :payment_order_status_id], name: "index_bpr_order_fields"
    add_index :payment_orders, [:deleted_at, :payment_order_status_id], name: "index_bpr_order_fields_2"
    add_index :payment_orders, [:deleted_at, :payment_purpose_id, ], name: "index_bpr_order_fields_3"

    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id, :owner_id], name: "index_bpr_awaiting_approval_fields"
    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id], name: "index_bpr_awaiting_approval_fields_2"
    add_index :bank_payment_requests, [:deleted_at, :policy_id, :controlling_level_id, :company_id], name: "index_bpr_awaiting_approval_fields_3"
    add_index :bank_payment_requests, [:deleted_at, :payment_order_id, :policy_id, :controlling_level_id, :company_id, :owner_id], name: "index_bpr_awaiting_approval_fields_4"
    add_index :bank_payment_requests, [:owner_id, :policy_id], name: "index_bpr_awaiting_approval_fields_5"

    add_index :document_level_reviewer_mappings, :document_reviewer_mappable_type, name: "index_dlrm_on_mappable_type"
    add_index :document_level_reviewer_mappings, :document_reviewer_mappable_id, name: "index_dlrm_on_mappable_id"
    add_index :document_level_reviewer_mappings, :level_number, name: "index_dlrm_on_level_number"
    add_index :document_level_reviewer_mappings, [:deleted_at, :document_reviewer_mappable_type, :reviewer_id, :forwarded], name: "index_dlrm_fields"
    add_index :document_level_reviewer_mappings, [:deleted_at, :document_reviewer_mappable_type, :reviewer_id, :forwarded_to_id, :taken_control_by_id], name: "index_dlrm_fields_2"
    add_index :document_level_reviewer_mappings, [:deleted_at, :document_reviewer_mappable_type, :reviewer_id, :forwarded_to_id, :taken_control_by_id], name: "index_dlrm_fields_3"

    add_index :policy_user_roles, [:policy_id, :user_role_id, :user_id], name: "index_pur_fields"
    add_index :policy_user_roles, [:user_role_id, :user_id], name: "index_pur_fields_2"

    add_index :payments, [:deleted_at, :payment_order_id], name: "index_payments_fields"
    add_index :payments, :payment_order_id
  end
end
