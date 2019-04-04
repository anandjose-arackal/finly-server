json.results do
  json.approved_purchase_request_items do
    json.array!((1..35).to_a) do |i|
      json.order_number "ASDF123"
      json.required_by_date Date.today
      json.delivery_location_id 1
      json.vendor_id 1
      json.vendor_name "Apple Tech"
      json.per_unit_estimated_amount 1000.50
      json.rate_contract "no"
      # json.per_unit_estimated_amount_attributes do
      #   json.currency_id line_item&.per_unit_estimated_amount&.currency_id
      #   json.value line_item&.per_unit_estimated_amount&.value
      #   json.id line_item&.per_unit_estimated_amount_id
      # end

      # json.estimated_amount_attributes do
      #   json.currency_id line_item&.estimated_amount&.currency_id
      #   json.value line_item&.estimated_amount&.value
      #   json.id line_item&.estimated_amount_id
      # end

      json.per_unit_estimated_amount_attributes do
        json.currency_id 1
        json.value 300
        json.id 222
      end

      json.estimated_amount_attributes do
        json.currency_id 1
        json.value 2223
        json.id 22
      end
      json.item_attributes do
        json.id 1
        json.name 'Pencil'
        json.quantity 5
      end
      json.location_attributes do
        json.id 1
        json.name 'Delhi'
      end
    end
  end
  json.count 35
end