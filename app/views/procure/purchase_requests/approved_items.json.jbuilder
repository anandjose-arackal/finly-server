json.results do
  json.approved_purchase_request_items do
    json.array!(@result.paginated_items) do |item|
      json.id item.id
      json.order_number "A"+ rand(1234).to_s
      json.required_by_date item&.required_by_date&.to_date
      json.delivery_location_id item&.delivery_location&.name
      json.vendor_id item&.vendor_id
      json.vendor_name item&.vendor&.name
      json.per_unit_estimated_amount item&.per_unit_estimated_amount&.value
      json.rate_contract 
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
        json.currency_id item&.per_unit_estimated_amount&.currency_id
        json.value item&.per_unit_estimated_amount&.value
        json.id item&.per_unit_estimated_amount_id
      end

      json.estimated_amount_attributes do
        json.currency_id item&.estimated_amount&.currency_id
        json.value item&.estimated_amount&.value
        json.id item&.estimated_amount_id
      end
      json.item_attributes do
        json.id item&.item&.id
        json.name item&.item&.description
        json.quantity item.quantity
      end
      json.location_attributes do
        json.id item.delivery_location_id
        json.name item.delivery_location&.name
      end
    end
  end
  json.count @result.count
end