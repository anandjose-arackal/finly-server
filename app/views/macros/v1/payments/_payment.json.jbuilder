exposure = record.to_exposure
json.id record.id
json.amount record.amount&.value
json.date exposure.date
json.reference_id exposure.reference_id
json.initiating_user_type record.initiating_user_type
json.initiating_user record.initiating_user
json.receiving_user_type record.receiving_user_type
json.receiving_account_type record.receiving_account_type
json.status record.status
json.payment_mode record.payment_mode
json.utr record.utr
json.created_at record.created_at
json.updated_at record.updated_at
json.processed_at record.processed_at
json.last_retried_at record.last_retried_at
json.note exposure.note
json.payment_order do
  json.submitted_at record.payment_order.bank_payment_request.submitted_at
  json.approved_at record.payment_order.bank_payment_request.approved_at
  json.processed_at record.payment_order&.processed_at
  json.description record.payment_order&.bank_payment_request&.description
end
json.parent_type exposure.parent_type_name
json.document do
  json.purchase_order do
    # PO Advance, Invoice Payments
    if record.parent_type == "PurchaseOrder"
      purchase_order = record.purchase_order_parent
      if purchase_order.present?
        json.po_number purchase_order&.po_number
        json.original_amount precision_value(purchase_order.total_after_tax&.value)
        json.total_advance_amount purchase_order.total_adv_amount
        json.payable_advance_amount precision_value(purchase_order.advance_amount&.value)
        json.balance_due precision_value(purchase_order.balance_amount&.value)
        json.tds_amount purchase_order.advance_tds_amount&.value
        json.tds purchase_order.advance_tds_slab&.tds
        json.tds_slab_id purchase_order.advance_tds_slab_id
        json.tds_slab_name purchase_order.advance_tds_slab&.name
        json.delivery_location purchase_order.delivery_location.as_json
        json.requested_advance_amount purchase_order.requested_advance_amount&.value
        json.vendor do
          # Invoice Payments/PO Advance/Beneficiary Payment/Security Deposit
          if purchase_order.vendor.present?
            json.partial! 'macros/v1/vendors/vendor', record:  purchase_order.vendor
          end
        end
      end
    elsif record.parent_type == "Invoice"
      json.po_number record.invoice_parent&.po_number
    end
  end
  json.invoice do
    # Invoice Payments
    if record.parent_type == 'Invoice' && record.invoice_parent.present?
      json.partial! 'macros/v1/invoices/invoice_header', record: record.invoice_parent
    end
  end
  json.bbps_bill do
    # Todo For BBPS Payments
  end
end
json.beneficiary do
  json.user do
    # Todo - For Prepaid Card payments
  end
  json.vendor do
    # Invoice Payments/PO Advance/Beneficiary Payment/Security Deposit
    if record.receiving_user_vendor.present?
      json.partial! 'macros/v1/vendors/vendor', record: record.receiving_user_vendor
    end
  end
  json.utility_bill_subscription do
    # Todo - BBPS Bills
  end
end
json.beneficiary_account do
  json.bank_account record.receiving_account_bank_account
  json.prepaid_card do
    # Todo - for money requests / reimbursements
  end
  json.cash_on_hand do
    # Todo - for money requests
  end
  json.bbps_biller do
    # Todo - For BBPS Payments
  end
  json.user_pocket do
    # Todo - For employee advances to pockets
  end
end

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at