
# sending all the currencies and the respective symbols and codes
json.currencies do
  json.array! @result.currencies do |currency|
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.id currency.id
  end
end

json.tds_slabs do
  json.array! @result.tds_slabs, :id, :tds, :name
end

json.config do
  json.em_tax_tracking @result.em_tax_tracking
  json.gstin_verification_enabled @result.user.company.gstin_verification_enabled?
end