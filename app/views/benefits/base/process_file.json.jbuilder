json.payment do
  json.items do
    json.array! @result.processed_order.each do |item|
      json.user do
        json.identifier item[:user][:identifier]
        user_obj = item[:user][:user_details]
        if user_obj.present?
          json.details do
            json.name user_obj.name
            json.email user_obj.email
            json.mobile_number user_obj.mobile_number
          end
        end
      end
      json.card do
        if item[:card].present?
          card_obj = item[:card]
          json.ending_number card_obj.ending_number
        end
      end
      json.amount item[:amount]
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