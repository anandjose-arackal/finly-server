json.data do
  json.array! @op['model'].result&.dig('predictions') do |item|
    json.name item.dig('structured_formatting', 'main_text')
    json.description item['description']
    json.maps_id item['place_id']
  end
end