json.balance @result.balance
json.collect_credit_account do
  json.account_number @result.collect_credit_account.account_number
  json.ifsc @result.collect_credit_account.ifsc
  json.name @result.collect_credit_account.name
end