json.array!(@result.locations) do |location|
  json.extract! location, :id, :name, :gstin, :pan, :address_1, :address_2, :city, :country, :pin, :address, :code
end