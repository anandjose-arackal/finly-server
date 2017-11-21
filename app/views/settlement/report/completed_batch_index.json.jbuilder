json.array! @result.paginated_report_processor_groups do |group|
  json.id group.id
  json.created_by_user group.created_by_user
  json.status group.status
  json.scheduled_at DateUtils.datetime_formatted group.scheduled_at
  json.completed_at DateUtils.datetime_formatted group.completed_at
  json.total_amount group.total_amount
  json.processed_amount group.processed_amount
  json.source_account_type group.source_account_type
  json.payment_type group.payment_type
  json.payment_mode group.payment_mode
  json.items do
    json.array! group.mappings do |item|
      json.user item.user
      json.amount item.amount
      json.completed_at DateUtils.datetime_formatted item.completed_at
      json.status item.status
      json.payment item.payment
      json.reports do
        json.array! item.reports do |report|

          json.extract! report, :id, :name
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
        json.array! item.system_messages
      end
    end
  end

end