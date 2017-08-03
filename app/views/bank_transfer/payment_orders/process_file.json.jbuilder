json.payment do
  json.items do
    json.array! @result.processed_order.each do |item|
      json.bank_account_number item[:bank_account_number]
      json.amount item[:amount]
      json.ifsc item[:ifsc]
      json.name item[:name]
      json.valid item[:valid]
      json.messages item[:messages]
    end
  end
  json.errors @result.errors
  json.payment_order_valid @result.payment_order_valid
  json.requested_amount @result.requested_amount
  json.processable_amount @result.processable_amount
  json.scheduled_at @result.scheduled_at_formatted
  json.created_at @result.created_at_formatted
end