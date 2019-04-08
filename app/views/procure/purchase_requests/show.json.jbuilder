json.result do
  json.purchase_request do
    json.id @result.purchase_request.id
    json.description @result.purchase_request&.description
    json.note @result.purchase_request&.note
    json.created_by do
      json.name @result.purchase_request.creator&.name
      json.created_at @result.purchase_request&.created_at&.to_date
    end
    json.status @result.purchase_request&.status&.name
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
    json.total_cost @result.purchase_request.purchase_request_items.join(:estimated_amount).pluck('value')&.flatten&.compact&.sum
    json.total_items @result.line_items_count
    json.line_items do
      if @result.line_items.present?
        json.array!(@result.line_items) do |line_item|
          json.id line_item.id
          json.product_details do
            json.product_name line_item&.item&.description
            json.id line_item.item_id
          end
          json.preferred_vendor do        
            json.name line_item&.vendor&.name
            json.id line_item.vendor_id
          end
          json.required_by_date line_item&.required_by_date&.to_date
          json.delivery_location do  
            json.name line_item&.delivery_location&.name
            json.id line_item.delivery_location_id
          end
          json.purpose line_item.purpose
          json.quantity line_item.quantity
          json.unit_type "each"
          json.estimated_cost do
            json.currency_id line_item&.estimated_amount&.currency_id
            json.value line_item&.estimated_amount&.value
            json.id  line_item&.estimated_amount_id
          end
          json.unit_cost do
            json.currency_id line_item&.per_unit_estimated_amount&.currency_id
            json.value line_item&.per_unit_estimated_amount&.value
            json.id line_item&.per_unit_estimated_amount_id
          end
          json.attachments_attributes do
            json.array!(line_item.attachments) do |attachment|
              json.uid attachment.id
              json.name attachment&.file_file_name
              json.url attachment&.attachment&.url
              # As required by frontend
              json.status 'done'
            end unless line_item.attachments.blank?
          end
        end
      else
        []
      end
    end
    # json.reviewal_chains do
    #   json.array! @result.reviewal_chains do |chain|
    #     json.policy_id chain[:policy_id]
    #     json.reviewal_chain do
    #       json.array! chain[:reviewal_chain] do |item|
    #         json.level_number item[:level_number]
    #         json.level_name item[:level_name]
    #         json.level_id item[:level_id]
    #         if item[:selected_reviewer].present?
    #           json.selected_reviewer do
    #             json.reviewer_details item[:selected_reviewer].as_json
    #             json.threshold item[:selected_reviewer_threshold]
    #           end
    #         end
    #         json.reviewers do
    #           json.array! item[:reviewers] do |reviewer|
    #             json.extract! reviewer, :id, :exception, :threshold
    #             json.reviewer_details reviewer.reviewer.as_json
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

    if @result.purchase_request.attachments.present?
      json.attachments_attributes do
        json.array!(@result.purchase_request.attachments) do |attachment|
          json.uid attachment.id
          json.name attachment&.file_file_name
          json.url attachment&.file&.url
          # As required by frontend
          json.status 'done'
        end
      end
    end
    json.reviewal_chain @result.purchase_request.get_reviewal_chain
  end
end
