json.distance_config do
  json.enabled @result.distance_config[:enabled]
  json.rate @result.distance_config[:rate]
  json.default_category_id @result.distance_config[:default_category_id]
end
json.time_config do
  json.enabled @result.time_config[:enabled]
  json.rate @result.time_config[:rate]
  json.default_category_id @result.time_config[:default_category_id]
end
json.per_diem_config do
  json.enabled @result.per_diem_config[:enabled]
  json.per_diems do
    json.array! @result.per_diem_config[:per_diems].each do |per_diem|
      json.name per_diem[:name]
      json.id per_diem[:id]
      json.rate do
        json.value per_diem[:rate]
        json.currency do
          json.extract! Currency.first, :id, :country, :country_code, :symbol
        end
      end
    end
  end
end
json.cash_on_hand do
  json.value @result.cash_on_hand
  json.currency Currency.first
end
json.custom_fields_config @result.custom_fields_config
json.currencies do
  json.array!(@result.currencies) do |currency|
    json.id currency.id
    json.symbol currency.symbol
    json.country_code currency.country_code
    json.country currency.country
  end
end
json.categories do
  json.array!(@result.categories) do |category|
    json.extract! category, :id, :name
  end
end

json.categories do
  json.array!(@result.categories) do |category|
    json.extract! category, :id, :name
  end
end

json.cash_pockets do
  json.array!(@result.cash_and_credit_pockets) do |pocket|
    if pocket.cash_pocket?
      adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
      json.can_claim_reimbursement true
    elsif pocket.credit_card_pocket?
      adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
      json.can_claim_reimbursement false
    else
      adapter = nil
      json.can_claim_reimbursement false
    end
    json.name pocket.name
    json.balance adapter&.balance(display_balance: true)
    json.id pocket.id

    currency = pocket.base_currency
    json.base_currency do
      json.symbol currency&.symbol
      json.country_code currency&.country_code
      json.id currency&.id
    end
  end
end