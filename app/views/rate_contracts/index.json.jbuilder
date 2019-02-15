json.results do
  json.array!(@result.paginated_rate_contracts) do |rate_contract|
    json.extract! rate_contract, :id, :name, :vendor_id, :renewal_alert, :creator_id
    json.rate_contract_count @result.count
    if rate_contract.rate_contract_line_items.present?
      json.line_items do
        json.array!(rate_contract.rate_contract_line_items) do |line_item|
          json.item_name line_item.item.hsn_sac
          json.start_name line_item.start_date&.to_date
          json.end_date line_item.end_date&.to_date
          json.amount line_item.amount
          json.rate_contract_id line_item.rate_contract_id
        end
      end
    end
  end
end