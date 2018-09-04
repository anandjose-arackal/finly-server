json.company_card_enabled @result.user.company.d_code_enabled?
json.data do
  json.merge! @result.balances
  json.actions @result.actions
  json.user_pockets do
    json.array!(@result.user_pockets) do |pocket|
      json.name pocket.name
      json.id pocket.id
      adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
      json.balance adapter.balance(display_balance: true)
      currency = pocket.base_currency
      json.base_currency do
        json.symbol currency&.symbol
        json.country_code currency&.country_code
        json.id currency&.id
      end
    end
  end
end