budget = @result.budget
json.extract! @result.budget, :id, :name, :budgetable_id, :budgetable_type

json.applicable_entities do
  json.purchase_order @result.budget.purchase_order
  json.payment @result.budget.payment
  json.expense @result.budget.expense
end

# json.period do
#   json.extract! @result.budget.period, :id, :name
# end

json.start_date @result.budget.start_date&.strftime("%d-%b-%Y")
json.end_date @result.budget.end_date&.strftime("%d-%b-%Y")

json.amounts do
  json.budget_amount do
    json.extract! @result.budget.budget_amount, :id, :value
  end
  # json.spent_amount do
  #   json.value @result.spent_amount
  # end
  json.currency do
    json.extract! @result.budget.budget_amount.currency, :id, :country, :country_code, :symbol
  end
end

# json.budget_trail_items do
#   json.array! @result.budget_trail_items do |item|
#     json.extract! item, :id, :date
#     json.amount do
#       json.value item.amount.value
#       json.currency do
#         json.extract! item.amount.currency, :id, :country, :country_code, :symbol
#       end
#     end
#
#     if item.class.name == 'Expense'
#       json.status item.expense_status.name.humanize
#       json.expense_type item.expense_type.name.humanize + " Expense"
#       json.type "expense"
#       json.user do
#         json.extract! item.user, :id, :name, :email, :mobile_number
#       end
#
#     elsif item.class.name == 'Payment'
#       json.status item.payment_status.name.humanize
#       json.type "payment"
#       if item.receiving_user.present?
#         json.vendor do
#           json.extract! item.receiving_user, :id, :name, :email, :mobile_number
#         end
#       end
#
#       if item.initiating_user.present?
#         json.initiating_user do
#           json.extract! item.initiating_user, :id, :name, :email, :mobile_number
#         end
#       end
#
#     end
#   end
# end

json.associated_vendors do
  json.array!(budget.budgetable_vendors) do |vendor|
    json.id vendor.id
    json.name vendor.name
  end
end
json.associated_categories do
  json.array!(budget.budgetable_categories) do |category|
    json.id category.id
    json.name category.name
  end
end
json.associated_cost_centers do
  json.array!(budget.budgetable_cost_centers) do |cost_center|
    json.id cost_center.id
    json.name cost_center.name
  end
end
json.associated_locations do
  json.array!(budget.budgetable_locations) do |location|
    json.id location.id
    json.name location.name
  end
end
json.associated_departments do
  json.array!(budget.budgetable_departments) do |department|
    json.id department.id
    json.name department.name
  end
end
json.associated_users do
  json.array!(budget.budgetable_users) do |user|
    json.id user.id
    json.name user.name
  end
end

json.user do
  json.extract! @result.budget.user, :id, :mobile_number, :email
end


