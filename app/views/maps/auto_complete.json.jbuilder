json.data do
  json.array! @op['model'].result&.dig('predictions') do |item|
    json.description item['description']
    json.place_id item['place_id']
  end
end