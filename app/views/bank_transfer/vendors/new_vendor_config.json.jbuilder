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
