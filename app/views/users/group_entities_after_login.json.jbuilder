json.companies do
  json.array!(@result.companies) do |company|
    json.name company.name
    json.logo company.configuration.logo.url
    json.company_id company.id
    json.subdomain company.subdomain
  end
end