json.partial! '/api/v1/users/user', user: @result.selected_user
json.actions @result.actions
json.wallet do
  json.balance @result.selected_user.wallet.balance_value
end