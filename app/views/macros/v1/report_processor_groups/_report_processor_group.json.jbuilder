json.id record.id
json.created_by_user record.created_by_user
json.status record.status
json.created_at DateUtils.date_formatted record.created_at
json.scheduled_on DateUtils.date_formatted record.scheduled_at
json.completed_on DateUtils.date_formatted record.completed_at
json.total_amount record.total_amount
json.processed_amount record.processed_amount
json.source_account_type record.source_account_type
json.payment_type record.payment_type
json.payment_mode record.payment_mode
json.items do
  json.array! record.mappings do |item|
    json.id item.id
    json.user item.user
    json.amount item.amount
    json.completed_on DateUtils.date_formatted item.completed_at
    json.status item.status
    json.payment item.payment
    json.receiving_account_type item.processor_accountable_type
    json.receiving_account item.processor_accountable
    json.note item.note
    utr = (item.bank_reference_number.present?) ? item.bank_reference_number : item.payment&.utr
    json.utr utr
    json.actions @result.item_actions(item)
    json.reports do
      json.array! item.reports.sort do |report|
        report_count += 1
        json.extract! report, :id, :policy, :date_as_string
        json.name "#{report.id} - #{report.name}"
        json.submitted_on DateUtils.date_formatted(report.submitted_at)
        json.approved_on DateUtils.date_formatted(report.approved_at)
        json.user report.user
        json.final_approver report.final_approver
        currency = Currency.first
        json.reimbursable_amount do
          json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount([:reimbursable]), currency: currency)
        end
        json.total_amount do
          json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount, currency: currency)
        end
        json.utr_number report.bank_reference_number.present? ? report.bank_reference_number : utr
        json.source_account report.source_account
      end
    end
  end
end

json.erp_sync_status record.erp_sync_status&.name
json.erp_sync_message record.erp_sync_message
json.erp_sync_reference_id record.erp_sync_reference_id
json.erp_sync_attempts_count record.erp_sync_attempts_count
json.erp_sync_attempted_at record.erp_sync_attempted_at

