json.result do
  json.approved_purchase_request_items do
    json.array!((1..35).to_a) do |i|
      json.order_number "ASDF123"
      json.item_id "12"
      json.quantity i
      json.quantity_unit "Litres"
      json.required_by_date Date.today
      json.delivery_location_id "1"
      json.vendor_id "1"
      json.vendor_name "Apple Tech"
      json.per_unit_estimated_amount "1000.50"
      json.rate_contract "no"
    end
  end
end