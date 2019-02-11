json.distance_config do
  json.enabled @result.distance_config[:enabled]
  json.vehicle_rates @result.distance_config[:vehicle_rates]
  # json.default_category_id @result.distance_config[:default_category_id]
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
      json.rate per_diem[:rate]
      json.currency per_diem[:currency]
    end
  end
end
json.custom_fields_config @result.custom_fields_config
json.currencies do
  json.array!(@result.currencies) do |currency|
    json.id currency.id
    json.symbol currency.symbol
    json.country_code currency.country_code
  end
end
json.cash_on_hand @result.cash_on_hand
json.categories do
  json.array!(@result.categories) do |category|
    json.extract! category, :id, :name
  end
end

json.custom_currency_conversion @result.custom_currency_conversion

json.config do
  json.em_tax_tracking @result.em_tax_tracking
end

json.tds_slabs do
  json.array! @result.tds_slabs, :id, :name, :tds
end

json.cash_pockets do
  json.array!(@result.cash_and_credit_pockets) do |pocket|
    case pocket.user_pocket_type_id
      when UserPocketType.id_for(:cash)
        adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        json.display_balance true
      when UserPocketType.id_for(:credit_card)
        adapter = AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(pocket)
        json.display_balance false
      when UserPocketType.id_for(:reimbursement)
        adapter = AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter.new(pocket)
        json.display_balance false
      when UserPocketType.id_for(:paid_by_company)
        adapter = AccountManager::PaidByCompanyPockets::PaidByCompanyPocketsAdapter.new(pocket)
        json.display_balance false
      else
        adapter = nil
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