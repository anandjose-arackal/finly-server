json.account_owner do
  json.extract! @result.account_owner, :id, :name, :email, :mobile_number
  if @result.account_owner.is_a?(YesBankVendor)
    json.authorized @result.account_owner.authorized
    json.description @result.account_owner.description
    json.editable_details (@result.user.permission.create_beneficiaries || @result.user.vendor_payments_admin?)
    json.pan @result.account_owner.pan
    json.gst @result.account_owner.gst
    json.tin @result.account_owner.tin
  else
    json.editable_details false
  end
  json.created_at @result.account_owner.created_at.strftime "%b %d %yy"
end
json.id @result.account_owner.id
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
    json.extract! payment, :id, :note, :payment_mode
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
if @result.account_owner.is_a?(YesBankVendor)
  json.attachment do
    json.url @result.account_owner.vendor_attachments.first&.attached_file&.url
    json.thumb @result.account_owner.vendor_attachments.first&.attached_file&.url(:thumb)
    json.file_type @result.account_owner.vendor_attachments.first&.attached_file_content_type
  end
end