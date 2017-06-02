@result.balances.each do |key,value|
	json.set! key, value
end