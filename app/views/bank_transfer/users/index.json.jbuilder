json.results do
  json.array!(@result.paginated_team) do |user|
  json.extract! user, :id, :email, :mobile_number, :name, :active

  # wallet_adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
  # Finly Credits
  # json.finly_money do
  #   json.balance wallet_adapter.balance
  #   json.currency do
  #     json.country_code user.bank_wallet.balance.currency.country_code
  #     json.symbol user.bank_wallet.balance.currency.symbol
  #   end
  # end

  # ain't nothing called cards here anyway, so ¯\_(ツ)_/¯
  end
end

json.count @result.users.count