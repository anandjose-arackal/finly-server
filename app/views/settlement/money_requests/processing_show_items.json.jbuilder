user_count = 0
request_count = 0
item_count = 0
json.items do
  json.array! @result.paginated_mappings do |item|
    user_count += 1
    item_count += 1
    json.id item.id
    json.user item.user
    json.amount item.amount
    json.completed_on DateUtils.datetime_formatted item.completed_at
    json.status item.status
    json.payment item.payment
    json.receiving_account_type item.processor_accountable_type
    json.receiving_account item.processor_accountable
    json.note item.note
    utr = (item.bank_reference_number.present?) ? item.bank_reference_number : item.payment&.utr
    json.utr utr
    json.actions @result.item_actions(item)
    json.money_requests do
      json.array! item.money_requests.sort do |money_request|

        request_count += 1
        json.extract! money_request, :id, :policy
        json.name "#{money_request.id} - #{money_request.name}"
        json.submitted_on DateUtils.date_formatted money_request.submitted_at
        json.approved_on DateUtils.date_formatted(money_request.approved_at)
        json.required_by_date DateUtils.date_formatted money_request.required_by_date
        json.approved_at DateUtils.date_formatted money_request.approved_at
        json.user money_request.user
        json.final_approver money_request.final_approver
        currency = money_request.base_currency
        json.total_amount do
          json.partial! 'shared/amount', amount: Amount.new(value: money_request.total_amount, currency: currency)
        end
        json.utr_number money_request.bank_reference_number.present? ? money_request.bank_reference_number : utr
        json.source_account money_request.source_account
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
json.request_count request_count
json.count item_count
