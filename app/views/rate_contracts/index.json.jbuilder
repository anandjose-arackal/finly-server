json.results do
  json.array!(@result.paginated_rate_contracts) do |rate_contract|
    json.merge! rate_contract.as_json
    json.vendor_name rate_contract&.vendor&.name
    if rate_contract.rate_contract_line_items.present?
      json.line_items do
        json.array!(rate_contract.rate_contract_line_items) do |line_item|
          json.item_name line_item&.item&.hsn_sac
          json.start_name line_item&.start_date&.to_date
          json.end_date line_item&.end_date&.to_date
          json.amount_id line_item&.amount
          json.amount_value line_item&.amount&.value
          json.amount_currency line_item&.amount&.currency
          json.rate_contract_id line_item&.rate_contract_id
          json.location_name line_item&.location&.name
        end
      end
    end
  end
end
json.count @result.count