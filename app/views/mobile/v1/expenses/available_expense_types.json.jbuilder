json.distance_config do
  json.enabled @result.distance_config[:enabled]
  json.rate @result.distance_config[:rate]
  json.default_category_id @result.distance_config[:default_category_id]
end
json.time_config do
  json.enabled @result.time_config[:enabled]
  json.rate @result.time_config[:rate]
  json.default_category_id @result.time_config[:default_category_id]
end
json.per_diem_config do
  json.enabled @result.per_diem_config[:enabled]
  json.per_diems do
    json.array! @result.per_diem_config[:per_diems].each do |per_diem|
      json.name per_diem[:name]
      json.id per_diem[:id]
      json.rate per_diem[:rate]
    end
  end
end
json.custom_fields_config @result.custom_fields_config