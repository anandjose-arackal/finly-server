json.array!(@result.paginated_team) do |user|
  json.extract! user, :id, :email, :mobile_number, :name

  # Finly Credits
  json.finly_money do
    json.balance user.bank_wallet.balance.value
    json.currency do
      json.country_code user.bank_wallet.balance.country.country_code
      json.symbol user.bank_wallet.balance.currency.symbol
    end
  end

  # ain't nothing called cards here anyway, so ¯\_(ツ)_/¯
end