json.array!(@result.pockets) do |pocket|
  adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
  json.name pocket.name
  json.balance adapter.balance
  json.id pocket.id
  currency = pocket.base_currency
  json.base_currency do
    json.symbol currency&.symbol
    json.country_code currency&.country_code
    json.id currency&.id
  end
end