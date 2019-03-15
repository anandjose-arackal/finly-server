json.array! @result.paginated_money_request_processors do |processor|
  json.id processor.id
  json.created_by_user processor.created_by_user
  json.status processor.status
  json.created_at DateUtils.date_formatted processor.created_at
  json.scheduled_on DateUtils.date_formatted processor.scheduled_at
  json.completed_on DateUtils.date_formatted processor.completed_at
  json.total_amount processor.total_amount
  json.processed_amount (processor.processed_amount || processor.total_amount)
  json.source_account_type processor.source_account_type
  json.payment_type processor.payment_type
  json.payment_mode processor.payment_mode
  user_count = 0
  money_request_count = 0
  json.items do
    json.array! processor.mappings do |item|
      if item.status.completed?
        user_count += 1
      end
      json.user item.user
      json.amount item.amount
      json.completed_on DateUtils.datetime_formatted item.completed_at
      json.status item.status
      json.payment item.payment
      json.receiving_account_type item.processor_accountable_type
      json.receiving_account item.processor_accountable
      json.note item.note
      json.money_requests do
        json.array! item.money_requests do |money_request|
          if item.status.completed?
            money_request_count += 1
          end
          json.extract! money_request, :id, :policy
          json.name "#{money_request.id} - #{money_request.name}"
          json.submitted_on DateUtils.date_formatted(money_request.submitted_at)
          json.approved_on DateUtils.date_formatted(money_request.approved_at)
          json.user money_request.user
          json.final_approver money_request.final_approver
          currency = money_request.base_currency
          json.total_amount do
            json.partial! 'shared/amount', amount: Amount.new(value: money_request.total_amount, currency: currency)
          end
        end
      end
      json.system_messages do
        json.array! item.system_messages
      end
    end
  end
  json.user_count user_count
  json.request_count money_request_count
end