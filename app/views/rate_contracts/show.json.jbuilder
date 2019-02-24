json.result do
  json.rate_contract do
    json.extract! @result.rate_contract, :id, :name, :vendor_id, :renewal_alert, :creator_id
    if @result.rate_contract.rate_contract_line_items.present?
      json.line_items do
        json.array!(@result.rate_contract.rate_contract_line_items) do |line_item|
          json.line_item_id  line_item.id
          json.item_name line_item&.item&.hsn_sac
          json.line_item_start_name line_item&.start_date&.to_date
          json.line_item_end_date line_item&.end_date&.to_date
          json.amount line_item&.amount
          json.rate_contract_id line_item&.rate_contract_id
          if line_item.artifacts.present?
            json.array!(line_item.artifacts) do |artifact|
              json.attachment = artifact&.attachment&.url
            end
          end
        end
      end
      json.attachments do
        if @result.rate_contract.artifacts.present?
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