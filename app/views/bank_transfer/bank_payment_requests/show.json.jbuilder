
json.summary do
  json.order_status_id @result.bank_payment_request.status_name(current_user.id)&.humanize
  json.bank_transfer_type @result.payment_order.payment_mode&.upcase
  json.payment_type @result.payment_order.payment_type.humanize
  json.scheduled_at @result.payment_order.scheduled_at&.strftime "%d %b %Y"
  json.processed_at @result.payment_order.processed_at&.strftime "%d %b %Y"
  json.amount_requested @result.payment_order.amount_requested&.value
  json.amount_processed @result.payment_order.amount_processed&.value
  json.description @result.bank_payment_request.description
  json.note @result.payment_order.note
  json.initiating_user @result.bank_payment_request.owner.name
  reviewer = (@result.manager.name rescue '--')
  json.reviewing_user reviewer
  creditor = (@result.finance_manager.name rescue '--')
  json.crediting_user creditor
  json.beneficiary_type @result.bank_payment_request.beneficiary_type
end

json.payments do
  json.array!(@result.payment_order.payments) do |payment|
    json.name payment.receiving_account.account_owner.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount payment.amount_value
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account.id
    json.beneficiary_type (payment.receiving_account.account_owner_type == "User" ? 1 : 2)
    json.system_messages do
      json.array! (payment.system_messages)
    end
    json.bank_reference_number payment.reference_resource&.bank_reference_number
  end
end

json.payments_verified do
  json.array!(@result.payments_verified) do |payment|
    json.name payment.receiving_account.account_owner.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount payment.amount_value
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account.id
    json.beneficiary_type (payment.receiving_account.account_owner_type == "User" ? 1 : 2)
    json.system_messages do
      json.array! (payment.system_messages)
    end
  end
end

json.payments_unverified do
  json.array!(@result.payments_unverified) do |payment|
    json.name payment.receiving_account.account_owner.name
    json.account_number payment.receiving_account.account_number
    json.ifsc payment.receiving_account.ifsc
    json.amount payment.amount_value
    json.status payment.payment_status_name
    json.id payment.id
    json.note payment.note
    json.account_id payment.receiving_account.id
    json.beneficiary_type (payment.receiving_account.account_owner_type == "User" ? 1 : 2)
    json.system_messages do
      json.array! (payment.system_messages)
    end
  end
end

json.attachments do
  json.array!(@result.payment_order.payment_order_attachments) do |attachment|
    json.id attachment.id
    json.url attachment.attached_file.url
    json.thumb attachment.attached_file.url(:thumb)
    json.description attachment.description
    json.file_type attachment.file_format(attachment.attached_file)
  end
end

json.comments do
  json.array!(@result.bank_payment_request.comments) do |comment|
    json.content comment.retrieve_content(current_user)
    json.timestamp comment.created_at.strftime "%I:%M %p, %d %b %Y"
    json.user do
      json.first_name comment.user&.first_name
      json.name comment.user&.name
      json.id comment.user&.id
    end
    json.action comment.action&.name
  end
end

json.actions @result.actions
