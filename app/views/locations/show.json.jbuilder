json.extract! @result.location, :id, :name, :gstin, :pan, :address_1, :address_2, :city, :state_id, :pin, :country, :location_code
json.states do
  json.array! @result.states, :id, :name
end