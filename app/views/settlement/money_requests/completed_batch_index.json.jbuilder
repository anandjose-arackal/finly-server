json.array! @result.paginated_money_request_processors do |processor|
  json.id processor.id
  json.created_by_user processor.created_by_user
  json.status processor.status
  json.created_at DateUtils.datetime_formatted processor.created_at
  json.scheduled_on DateUtils.datetime_formatted processor.scheduled_at
  json.completed_on DateUtils.datetime_formatted processor.completed_at
  json.total_amount processor.total_amount
  json.processed_amount processor.processed_amount
  json.source_account_type processor.source_account_type
  json.payment_type processor.payment_type
  json.payment_mode processor.payment_mode
  json.items do
    json.array! processor.mappings do |item|
      json.user item.user
      json.amount item.amount
      json.completed_on DateUtils.datetime_formatted item.completed_at
      json.status item.status
      json.payment item.payment
      json.money_requests do
        json.array! item.money_requests do |money_request|

          json.extract! money_request, :id, :name
          json.user money_request.user
          json.final_approver money_request.final_approver
          currency = Currency.first
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

end