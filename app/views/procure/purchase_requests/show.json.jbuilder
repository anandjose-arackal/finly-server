json.result do
  json.purchase_request do
    json.id @result.purchase_request.id
    json.description @result.purchase_request&.description
    json.created_by do
      json.name @result.purchase_request.creator&.name
      json.created_at @result.purchase_request&.created_at&.to_date
    end
    json.status @result.purchase_request&.purchase_request_status_id
    json.location do
      json.name @result.purchase_request&.location&.name
      json.id @result.purchase_request&.location_id
    end
    json.department do
      json.name @result.purchase_request&.department&.name
      json.id @result.purchase_request&.department_id
    end
    json.policy do 
      json.name @result.purchase_request.policy&.name
      json.id @result.purchase_request&.policy_id
    end
    json.total_cost "5000000"
    json.total_items @result.line_items_count
    json.line_items do
      if @result.line_items.present?
        json.array!(@result.line_items) do |line_item|
          json.id line_item.id
          json.product_details do
            json.product_name line_item.item.description
            json.id line_item.item_id
          end
          json.preferred_vendor do        
            json.name line_item&.vendor&.name
            json.id line_item.vendor_id
          end
          json.required_by_date line_item.required_by_date
          json.delivery_location do  
            json.name line_item&.delivery_location&.name
            json.id line_item.delivery_location_id
          end
          json.purpose line_item.purpose
          json.quantity line_item.quantity
          json.unit_type "each"
          json.estimated_cost do
            json.currency_id 1
            json.value 70002.0
            json.id  8838784
          end
          json.unit_cost do
            json.currency_id line_item&.per_unit_estimated_amount&.currency_id
            json.value line_item&.per_unit_estimated_amount&.value
            json.id line_item&.per_unit_estimated_amount_id
          end
        end
      else
        []
      end
    end
    
  end
end
