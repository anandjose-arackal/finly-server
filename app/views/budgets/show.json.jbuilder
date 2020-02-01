budget = @op["model"]
json.extract! budget, :id, :name, :user

json.applicable_entities do
  json.purchase_order budget.purchase_order
  json.payment budget.payment
  json.expense budget.expense
  json.invoice budget.invoice
  json.purchase_request budget.purchase_request
end

json.start_date budget.start_date&.strftime("%d-%b-%Y")
json.end_date budget.end_date&.strftime("%d-%b-%Y")

budget_consumption = budget.budget_consumption
json.budget_consumption budget_consumption

json.budget_criteria budget.budget_criteria_as_json

json.budget_trail_items do
  # TODO - change below to actual numbers lol
  json.expenses Expense.limit(10)
  json.payments Payment.limit(10)
  json.purchase_order_items PurchaseOrderItem.limit(10)
  json.invoice_items InvoiceLineItem.limit(10)
  json.purchase_request_items PurchaseRequestItem.limit(10)

  json.expenses_count 10
  json.payments_count 10
  json.purchase_order_items_count 10
  json.invoice_items_count 10
  json.purchase_request_items_count 10
end

# json.amounts do
#   json.budget_amount do
#     # json.extract! @result.budget.budget_amount, :id, :value
#     json.id budget.budget_amount&.id
#     json.value budget.budget_amount&.value
#   end
#   json.spent_amount do
#
#   end
#   json.currency do
#     # json.extract! @result.budget.budget_amount.currency, :id, :country, :country_code, :symbol
#     json.id @result.budget.budget_amount&.currency&.id
#     json.country @result.budget.budget_amount&.currency&.country
#     json.country_code @result.budget.budget_amount&.currency&.country_code
#     json.symbol @result.budget.budget_amount&.currency&.symbol
#   end
# end

# json.sub_budgets do
#   json.array!(budget.children) do |sub_budget|
#     json.extract! sub_budget, :id, :name, :created_by_user
#
#     json.start_date sub_budget.start_date&.strftime("%d-%b-%Y")
#     json.end_date sub_budget.end_date&.strftime("%d-%b-%Y")
#
#     budget_consumption = sub_budget.budget_consumption
#     json.budget_consumption budget_consumption
#
#     json.budget_criteria sub_budget.budget_criteria_as_json
#   end
# end

# json.associated_vendors do
#   json.array!(budget.budgetable_vendors) do |vendor|
#     json.id vendor.id
#     json.name vendor.name
#   end
# end
# json.associated_categories do
#   json.array!(budget.budgetable_categories) do |category|
#     json.id category.id
#     json.name category.name
#   end
# end
# json.associated_cost_centers do
#   json.array!(budget.budgetable_cost_centers) do |cost_center|
#     json.id cost_center.id
#     json.name cost_center.name
#   end
# end
# json.associated_locations do
#   json.array!(budget.budgetable_locations) do |location|
#     json.id location.id
#     json.name location.name
#   end
# end
# json.associated_departments do
#   json.array!(budget.budgetable_departments) do |department|
#     json.id department.id
#     json.name department.name
#   end
# end
# json.associated_users do
#   json.array!(budget.budgetable_users) do |user|
#     json.id user.id
#     json.name user.name
#   end
# end

# json.sub_budgets do
#   json.array!(budget.children) do |sub_budget|
#     json.extract! sub_budget, :id, :name
#
#     json.start_date sub_budget.start_date&.strftime("%d-%b-%y")
#     json.end_date sub_budget.end_date&.strftime("%d-%b-%y")
#
#     json.budget_amount do
#       # json.extract! sub_budget.budget_amount, :id, :value, :currency_id
#       json.id @result.budget.budget_amount&.id
#       json.value @result.budget.budget_amount&.value
#       json.currency_id @result.budget.budget_amount&.currency_id
#     end
#
#     processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(sub_budget)
#     json.spent_amount do
#       spent_amount = processor_instance.spent_amount
#       json.spent_amount spent_amount
#     end
#
#     json.amounts do
#       json.budget_amount do
#         # json.extract! @result.budget.budget_amount, :id, :value
#         json.id @result.budget.budget_amount&.id
#         json.value @result.budget.budget_amount&.value
#       end
#       json.spent_amount do
#         json.value @result.spent_amount
#       end
#       json.currency do
#         # json.extract! @result.budget.budget_amount.currency, :id, :country, :country_code, :symbol
#         json.id @result.budget.budget_amount&.currency&.id
#         json.country @result.budget.budget_amount&.currency&.country
#         json.country_code @result.budget.budget_amount&.currency&.country_code
#         json.symbol @result.budget.budget_amount&.currency&.symbol
#       end
#     end
#
#     json.associated_vendors do
#       json.array!(sub_budget.budgetable_vendors) do |vendor|
#         json.id vendor.id
#         json.name vendor.name
#       end
#     end
#     json.associated_categories do
#       json.array!(sub_budget.budgetable_categories) do |category|
#         json.id category.id
#         json.name category.name
#       end
#     end
#     json.associated_cost_centers do
#       json.array!(sub_budget.budgetable_cost_centers) do |cost_center|
#         json.id cost_center.id
#         json.name cost_center.name
#       end
#     end
#     json.associated_locations do
#       json.array!(sub_budget.budgetable_locations) do |location|
#         json.id location.id
#         json.name location.name
#       end
#     end
#     json.associated_departments do
#       json.array!(sub_budget.budgetable_departments) do |department|
#         json.id department.id
#         json.name department.name
#       end
#     end
#     json.associated_users do
#       json.array!(sub_budget.budgetable_users) do |user|
#         json.id user.id
#         json.name user.name
#       end
#     end
#
#     json.user do
#       json.extract! sub_budget.user, :id, :mobile_number, :email
#     end
#   end
# end


