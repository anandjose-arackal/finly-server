json.result do
  json.rate_contract do
    json.extract! @result.rate_contract, :id, :name, :vendor_id, :renewal_alert_number, :renewal_alert_period_id, :creator_id, :renewable
    if @result.rate_contract.rate_contract_line_items.present?
      json.line_items do
        json.array!(@result.rate_contract.rate_contract_line_items) do |line_item|
          json.id  line_item.id
          json.item_id line_item&.item_id
          json.item_name line_item&.item&.hsn_sac
          json.item_code line_item&.item&.item_code
          json.location_id line_item&.location_id
          json.location_name line_item&.location&.name
          json.location_code line_item&.location&.location_code
          json.line_item_start_date line_item&.start_date&.to_date
          json.line_item_end_date line_item&.end_date&.to_date
          json.amount_id line_item&.amount&.id
          json.rate_contract_id line_item&.rate_contract_id
          json.amount_attributes do
            json.currency_id line_item&.amount&.currency_id
            json.value line_item&.amount&.value
          end
          if line_item.artifacts.present?
            json.artifacts_attributes do
              json.array!(line_item.artifacts) do |artifact|
                json.uid artifact.id
                json.name artifact&.attachment_file_name
                json.url artifact&.attachment&.url
                json.status 'done'
              end
            end
          end
        end
      end
      
      if @result.rate_contract.artifacts.present?
        json.artifacts_attributes do
          json.array!(@result.rate_contract.artifacts) do |artifact|
            json.uid artifact.id
            json.name artifact&.attachment_file_name
            json.url artifact&.attachment&.url
            json.status 'done'
          end
        end
      end
    end
  end
end