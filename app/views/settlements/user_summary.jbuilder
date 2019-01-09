json.company_card_enabled @result.user.company.d_code_enabled?
json.data do
  json.merge! @result.balances
  json.actions @result.actions
  json.user_pockets do
    json.array!(@result.user_pockets) do |pocket|
      json.name pocket.name
      json.id pocket.id
      case pocket.user_pocket_type_id
      when UserPocketType.id_for(:cash)
        adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        json.display_balance true
      when UserPocketType.id_for(:credit_card)
        adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
      when UserPocketType.id_for(:reimbursement)
        adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(pocket)
      when UserPocketType.id_for(:paid_by_company)
        adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(pocket)
      else
        adapter = nil
      end
      json.balance adapter&.balance(display_balance: true)
      currency = pocket.base_currency
      json.base_currency do
        json.symbol currency&.symbol
        json.country_code currency&.country_code
        json.id currency&.id
      end
    end
  end
end