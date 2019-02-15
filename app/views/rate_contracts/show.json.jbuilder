json.result do
  json.rate_contract do
    json.extract! @result.rate_contract, :id, :name, :vendor_id, :renewal_alert, :creator_id
    if @result.rate_contract.rate_contract_line_items.present?
      json.line_items do
        json.array!(@result.rate_contract.rate_contract_line_items) do |line_item|
          json.line_item_id  line_item.id
          json.item_name line_item.item.hsn_sac
          json.line_item_start_name line_item.start_date&.to_date
          json.line_item_end_date line_item.end_date&.to_date
          json.amount line_item.amount
          json.rate_contract_id line_item.rate_contract_id
        end
      end
    end
  end
end