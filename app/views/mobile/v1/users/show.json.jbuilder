json.partial! '/api/v1/users/user', user: @result.selected_user
json.actions do 
	@result.actions.each do |key, value|
		json.set! key, value
	end
end
json.wallet do
  json.balance @result.selected_user.wallet.balance_value
end