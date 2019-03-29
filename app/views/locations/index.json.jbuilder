# json.locations do
#   json.array!(@result.locations) do |location|
#     json.merge! location.as_json
#   end
# end

json.array!(@result.locations) do |location|
  json.extract! location, :id, :name, :gstin, :pan, :address_1, :address_2, :city, :country, :pin, :address
end
