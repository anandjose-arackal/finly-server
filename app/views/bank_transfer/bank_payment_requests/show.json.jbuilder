json.summary do
  json.order_status do
    json.name @result.bank_payment_request.status_name(current_user.id)&.humanize
    json.identifier @result.bank_payment_request.status_name(current_user.id)
  end
  json.policy do
    json.id @result.bank_payment_request.policy&.id
    json.name @result.bank_payment_request.policy&.name
  end
  # json.retriable @result.bank_payment_request.retriable?
  json.bank_transfer_type @result.payment_order.payment_mode&.upcase
  json.payment_type @result.payment_order.payment_type&.humanize
  json.scheduled_at @result.payment_order.scheduled_at&.strftime "%d %b %Y"
  json.processed_at @result.payment_order.processed_at&.strftime "%d %b %Y"
  json.submitted_at @result.bank_payment_request.submitted_at&.strftime("%d %b %Y")
  json.amount_requested precision_value @result.payment_order.amount_requested&.value
  json.amount_processed precision_value @result.payment_order.amount_processed&.value
  json.description @result.bank_payment_request.description
  json.note @result.payment_order.note
  json.initiating_user @result.bank_payment_request.owner.name
  reviewer = (@result.manager.name rescue '--')
  json.reviewing_user reviewer
  creditor = (@result.finance_manager.name rescue '--')
  json.crediting_user creditor
  json.beneficiary_type @result.bank_payment_request.beneficiary_type
  json.approvers @result.approvers
  json.name @result.bank_payment_request.name
  json.show_payment_file_download (current_company.payment_file_configuration.present? && (current_user.company_admin? || current_user.vendor_payments_creditor?))

  json.verified_payments_count @result.payments_verified
  json.unverified_payments_count @result.payments_unverified
end

json.invoice_categories do
  json.array!(@result.invoice_categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.invoice_line_items_categories do
  json.array!(@result.invoice_line_items_categories) do |category|
    json.id category.id
    json.name category.name
  end
end

json.cost_centers do
  json.array!(current_company.cost_centers.with_application(RequestStoreUtil.current_app)) do |cost_center|
    json.id cost_center.id
    json.name cost_center.name
  end
end
json.tds_slabs do
  json.array!(current_company.tds_slabs) do |tds_slab|
    json.id tds_slab.id
    json.name "#{tds_slab.tds}% - #{tds_slab.name} "
    json.tds tds_slab.tds
  end
end

json.invoice_custom_fields @result.invoice_custom_fields

json.invoice_line_items_custom_fields @result.invoice_line_items_custom_fields

json.attachments do
  json.array!(@result.payment_order.payment_order_attachments) do |attachment|
    json.id attachment.id
    json.url attachment.attached_file.url(:default, timestamp: false)
    json.thumb attachment.attached_file.url(:thumb)
    json.description attachment.description
    json.file_type attachment.file_format(attachment.attached_file)
    json.content_type attachment.attached_file.content_type
    json.file_name attachment.attached_file.original_filename
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

json.counts do
  json.completed_count @result.bank_payment_request.payments.successful.count
  json.failed_count @result.bank_payment_request.payments.failed.count
  json.processing_count @result.bank_payment_request.payments.processing.count
  json.possible_failure_count @result.bank_payment_request.payments.possible_failure.count
  json.pending_count @result.bank_payment_request.payments.pending.count
  json.in_progress_count @result.bank_payment_request.payments.in_progress.count
  json.pending_approval_count @result.bank_payment_request.payments.pending_approval.count
end

json.actions @result.actions

json.budgets do
  json.array! @result.budgets do |budget|
    json.extract! budget[:budget], :budgetable_id, :budgetable_type, :start_date, :id, :name, :start_date, :end_date
    json.user budget[:budget].user.as_json
    json.spent_amount budget[:spent_amount]
    json.budget_amount budget[:budget].budget_amount.as_json
  end
end