json.codes do
  json.array! @result.states, :id, :name
end
json.vendor_types do
  json.array! @result.vendor_types, :id, :name
end

json.payment_terms do
  json.array! @result.payment_terms, :id, :name, :description
end

json.currencies do
  json.array! @result.currencies do |currency|
    json.merge! currency.as_json
  end
end

json.tds_rates do
  json.array! @result.tds_rates do |tds_rate|
    json.extract! tds_rate, :id, :name, :tds
  end
end

json.custom_fields_config @result.field_configurations
