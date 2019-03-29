json.locations do
  json.array!(@result.locations) do |location|
    json.merge! location.as_json
  end
end