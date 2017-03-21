json.distance_config do
  json.enabled @result.distance_config[:enabled]
  json.rate_per_km @result.distance_config[:rate_per_km]
  json.default_category_id @result.distance_config[:default_category_id]
  json.default_category_name @result.distance_config[:default_category_name]
end
json.time_config do
  json.enabled @result.time_config[:enabled]
  json.rate_per_hour @result.time_config[:rate_per_hour]
  json.default_category_id @result.time_config[:default_category_id]
  json.default_category_name @result.distance_config[:default_category_name]
end
json.per_diem_config do
  json.enabled @result.per_diem_config[:enabled]
  json.per_diems do
    json.array! @result.per_diem_config[:per_diems].each do |per_diem|
      json.name per_diem[:name]
      json.rate per_diem[:rate]
      json.id per_diem[:id]
    end
  end
end

json.extract! @result.categories