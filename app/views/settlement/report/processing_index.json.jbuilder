json.array! @result.paginated_report_processor_groups do |group|
  json.id group.id
  json.created_by_user group.created_by_user
  json.status group.status
  json.created_at DateUtils.date_formatted group.created_at
  json.scheduled_on DateUtils.date_formatted group.scheduled_at
  json.completed_on DateUtils.date_formatted group.completed_at
  json.total_amount group.total_amount
  json.processed_amount group.processed_amount
  json.source_account_type group.source_account_type
  json.payment_type group.payment_type
  json.payment_mode group.payment_mode
  json.actions @result.actions_for(group)
  user_count = 0
  report_count = 0
  json.items do
    json.array! group.mappings do |item|
      user_count += 1
      json.user item.user
      json.amount item.amount
      json.completed_on DateUtils.date_formatted item.completed_at
      json.status item.status
      json.payment item.payment
      json.receiving_account_type item.processor_accountable_type
      json.receiving_account item.processor_accountable
      json.note item.note
      json.reports do
        json.array! item.reports do |report|

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
end