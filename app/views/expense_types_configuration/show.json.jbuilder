json.distance_config do
  json.enabled @result.distance_config[:enabled]
  json.rate_per_km @result.distance_config[:rate_per_km]
  json.default_category_id @result.distance_config[:default_category_id]
end
json.time_config do
  json.enabled @result.time_config[:enabled]
  json.rate_per_km @result.time_config[:rate_per_km]
  json.default_category_id @result.time_config[:default_category_id]
end
json.per_diem_config do
  json.enabled @result.per_diem_config[:enabled]
  json.array! @result.per_diem_config[:per_diems].each do |per_diem|
    json.name per_diem[:name]
    json.rate per_diem[:rate]
  end
end

json.extract! @result.categories