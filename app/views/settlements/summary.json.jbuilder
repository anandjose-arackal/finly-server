json.company_card_enabled @result.user.company.itz_cash_property.d_code.present? rescue false
json.data do
  json.merge! @result.balances
  json.actions @result.actions
end
