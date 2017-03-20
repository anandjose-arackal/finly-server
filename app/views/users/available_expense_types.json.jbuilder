json.distance_config do
  json.enabled @result.distance_config[:enabled]
end
json.time_config do
  json.enabled @result.time_config[:enabled]
end
json.per_diem_config do
  json.enabled @result.per_diem_config[:enabled]
  json.per_diems do
    json.array! @result.per_diem_config[:per_diems].each do |per_diem|
      json.name per_diem[:name]
      json.id per_diem[:id]
    end
  end
end