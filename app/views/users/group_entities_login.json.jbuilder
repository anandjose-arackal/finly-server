json.array!(@result.companies) do |company|
  json.name company.name
  json.logo company.configuration.logo.url
end