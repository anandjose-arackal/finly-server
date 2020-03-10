json.data do
  result = @op['model'].result['result']
  json.name result['name']
  json.address result['formatted_address']
  json.place_id result['place_id']
  json.latitude result&.dig('geometry', 'location', 'lat')
  json.longitude result&.dig('geometry', 'location', 'lng')
end