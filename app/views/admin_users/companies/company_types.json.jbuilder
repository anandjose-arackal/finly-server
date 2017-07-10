
json.array!(@company_types) do |type|
  json.id type.id
  json.name type.name
end