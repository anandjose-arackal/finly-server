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
      json.rate do
        json.value per_diem[:rate]
        json.currency do
          json.extract! Currency.first, :id, :country, :country_code, :symbol
        end
      end
    end
  end
end
json.custom_fields_config @result.custom_fields_config
json.currencies do
  json.array!(@result.currencies) do |currency|
    json.id currency.id
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.country currency.country
  end
end
json.categories do
  json.array!(@result.categories) do |category|
    json.extract! category, :id, :name
  end
end