user_count = 0
report_count = 0
item_count = 0
json.items do
  json.array! @result.paginated_mappings do |item|
    user_count += 1
    item_count += 1
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
    json.system_messages do
      messages = []
      messages = messages + item.system_messages if item.system_messages.present?
      messages = messages + item.payment.system_messages if item.payment&.system_messages&.present?
      json.array! messages
    end
  end
end
json.user_count user_count
json.report_count report_count
json.count item_count