json.codes do
  json.array! @result.states, :id, :name
end
json.vendor_types do
  json.array! @result.vendor_types, :id, :name
end