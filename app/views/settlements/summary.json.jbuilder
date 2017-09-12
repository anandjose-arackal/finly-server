json.company_card_enabled @result.user.company.d_code_enabled?
json.data do
  json.merge! @result.balances
  json.actions @result.actions
end