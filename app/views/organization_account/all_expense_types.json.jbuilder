json.expense_types do
	json.array!(@result) do |expense_types|
		# p '####################################'
		# p expence_type
		json.id expense_type.id
	end
end