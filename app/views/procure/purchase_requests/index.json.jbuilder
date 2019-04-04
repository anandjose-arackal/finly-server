# this is a sample for the frontend
# json.array!((1..10).to_a) do |i|
#   json.id i
#   json.title "Sample Title"
#   json.department "Sample Dept"
#   json.location "Valhalla - #{i}"
#   json.total_items i*3
#   json.created_by do
#     json.name "What's in a name"
#     json.created_at Date.today-rand(10000)
#   end
#   json.status ["Delivered", "Pending", "Rejected", "Draft", "Awaiting Approval"][rand(5).to_i]
# end

json.results do
  json.array!(@result.paginated_purchase_requests) do |purchase_request|
    json.merge! purchase_request.as_json
    if purchase_request.purchase_request_items.present?
      json.line_items do
        json.array!(purchase_request.purchase_request_items) do |line_item|
          json.purchase_request_id line_item.purchase_request_id
          json.item_id line_item.item_id
          json.item_name line_item.item&.description
          json.vendor_id line_item.vendor_id
          json.vendor_name line_item.vendor&.name
          json.delivery_location_id line_item.delivery_location_id
          json.delivery_location_name line_item.delivery_location&.name
          json.quantity line_item.quantity
          json.required_by_date line_item&.required_by_date&.to_date
          json.status_id line_item.status_id
          json.status_name line_item.status&.name
          json.purchase_order_id json.purchase_order_id

          json.per_unit_estimated_amount_attributes do
            json.currency_id line_item&.per_unit_estimated_amount&.currency_id
            json.value line_item&.per_unit_estimated_amount&.value
            json.id line_item&.per_unit_estimated_amount_id
          end

          json.estimated_amount_attributes do
            json.currency_id line_item&.estimated_amount&.currency_id
            json.value line_item&.estimated_amount&.value
            json.id line_item&.estimated_amount_id
          end
        end
      end
    else
      json.line_items []
    end
  end
end
json.count @result.count