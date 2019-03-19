json.vendor do
  json.extract! @result.vendor, :id, :name, :email, :mobile_number
  if @result.vendor.is_a?(YesBankVendor)
    json.payment_term @result.vendor.payment_term
    json.currency @result.vendor.currency
    json.business_name @result.vendor.business_name
    json.address @result.vendor.address
    json.authorized @result.vendor.authorized
    json.description @result.vendor.description
    json.editable_details (@result.user.permission.create_beneficiaries || @result.user.vendor_payments_admin?)
    json.pan @result.vendor.pan
    json.gst @result.vendor.gst
    json.tin @result.vendor.tin
    json.state_code_id @result.vendor.state_code_id
    json.state_code_name @result.vendor.state_code&.full_name
    json.created_by @result.vendor.created_by&.name
    json.vendor_id @result.vendor.vendor_id
  else
    json.editable_details false
  end
  json.created_at @result.vendor.created_at.strftime "%b %d %yy"
end
json.id @result.vendor.id
json.bank_accounts do
  json.array!(@result.bank_accounts) do |bank_account|
    json.account_number bank_account.account_number
    json.ifsc bank_account.ifsc
    json.id bank_account.id
    json.name bank_account.name
    json.default bank_account.default_account
  end
end
json.transactions do
  json.array!(@result.receiving_transactions) do |payment|
    json.extract! payment, :id, :note
    json.reference_id payment.reference_resource&.bank_reference_number
    json.amount payment.amount.value
    json.date payment.date
    json.bank_payment_request_id payment.payment_order&.bank_payment_request&.id
    json.payment_mode payment.payment_mode&.upcase
    json.account_number payment.receiving_account&.account_number
    json.ifsc payment.receiving_account&.ifsc
    json.initiating_user_name payment.initiating_user&.name
    json.payment_status payment.payment_status_name
  end
end
if @result.vendor.is_a?(YesBankVendor)
  json.attachments do
    json.array! @result.vendor.vendor_attachments do |attachment|
      json.id attachment.id
      json.url attachment.attached_file&.url
      json.thumb attachment.attached_file&.url(:thumb)
      json.file_type attachment.attached_file_content_type
      json.attachment_type attachment.attachment_type
    end
  end

  json.vendor_type do
    json.id @result.vendor.vendor_type&.id
    json.name @result.vendor.vendor_type&.name
  end


  json.procurement_data do
    json.purchase_orders do
      json.array! @result.procurement_data[:purchase_orders] do |po|
        json.extract! po, :id, :po_number, :procurement_id
        json.created_by po.user&.name
        json.created_at po.created_at&.strftime("%d-%b-%Y")
        json.amount po.balance_amount&.value
      end
    end

    json.non_po_invoices do
      json.array! @result.procurement_data[:non_po_invoices] do |invoice|
        json.extract! invoice, :id, :invoice_id, :invoice_number, :procurement_id
        json.created_by invoice.created_by&.name
        json.created_at invoice.created_at&.strftime("%d-%b-%Y")
        json.amount invoice.net_amount&.value
      end
    end

 end
end

json.actions @result.actions

json.custom_fields do
  json.array! @result.custom_fields
end
