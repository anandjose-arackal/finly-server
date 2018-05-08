json.extract! @result.budget, :id, :name, :budgetable_id, :budgetable_type
json.period do 
  json.extract! @result.budget.period, :id, :name
end

json.start_date @result.budget.start_date&.strftime("%d-%b-%y")
json.end_date @result.budget.end_date&.strftime("%d-%b-%y")

json.budget_amount do
  json.extract! @result.budget.budget_amount, :id, :value, :currency_id
end

json.user do
  json.extract! @result.budget.user, :id, :mobile_number, :email
end
