json.company_card_enabled @result.user.company.d_code_enabled?
json.bank_transfer_enabled @result.user.bank_transfer_enabled?
json.data do
  json.merge! @result.balances
  json.actions @result.actions
end