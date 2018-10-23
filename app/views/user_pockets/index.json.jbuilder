json.array!(@result.pockets) do |pocket|
  case pocket.user_pocket_type_id
  when UserPocketType.id_for(:cash)
    adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
  when UserPocketType.id_for(:credit_card)
    adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
  when UserPocketType.id_for(:reimbursement)
    adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(pocket)
  when UserPocketType.id_for(:paid_by_company)
    adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(pocket)
  else
    adapter = nil
  end
  json.name pocket.name
  json.balance adapter&.balance
  json.id pocket.id
  currency = pocket.base_currency
  json.base_currency do
    json.symbol currency&.symbol
    json.country_code currency&.country_code
    json.id currency&.id
  end
end