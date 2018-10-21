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
  json.spent_amount do
    json.value @result.spent_amount
  end
  json.currency do
    json.extract! @result.budget.budget_amount.currency, :id, :country, :country_code, :symbol
  end
end

json.budget_trail_items do
  index = 1
  # first will be the list of expenses
  json.expenses do
    json.array!(@result.spent_entities[0]) do |expense|
      json.user_name expense.user&.name
      json.category_name expense.category&.name
      json.date expense.date.strftime("%Y-%B-%d")
      json.amount expense.amount&.value
      json.index index
      index += 1
    end
  end

  # list of payments that need to be processed
  json.payments do
    json.array!(@result.spent_entities[1]) do |payment|
      json.vendor payment.receiving_user&.name
      json.category_name payment.category&.name
      json.cost_center_name payment.cost_center&.name
      json.amount payment.amount&.value
      json.date payment.date.strftime("%Y-%B-%d")
      json.index index
      index += 1
    end
  end

  # list of purchase order items
  json.purchase_order_items do
    json.array!(@result.spent_entities[2]) do |purchase_order_item|
      json.name purchase_order_item.description
      json.cost_center_name purchase_order_item.cost_center&.name
      json.amount purchase_order_item.total_amount&.value
      json.date purchase_order_item.purchase_order.delivery_date
      json.location purchase_order_item.purchase_order.location&.name
      json.department purchase_order_item.purchase_order.department&.name
      json.index index
      index += 1
    end
  end

  # list of invoice line items
  json.invoice_items do
    json.array!(@result.spent_entities[3]) do |invoice_line_item|
      json.name invoice_line_item.description
      json.cost_center_name invoice_line_item.parent.cost_center&.name
      json.amount invoice_line_item.net_amount&.value
      json.date invoice_line_item.parent.date.strftime("%Y-%B-%d")
      json.location invoice_line_item.parent.location&.name
      json.department invoice_line_item.parent.department&.name
      json.index index
      index += 1
    end
  end
end

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

json.sub_budgets do
  json.array!(budget.children) do |sub_budget|
    json.extract! sub_budget, :id, :name

    json.start_date sub_budget.start_date&.strftime("%d-%b-%y")
    json.end_date sub_budget.end_date&.strftime("%d-%b-%y")

    json.budget_amount do
      json.extract! sub_budget.budget_amount, :id, :value, :currency_id
    end

    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(sub_budget)
    json.spent_amount do
      spent_amount = processor_instance.spent_amount
      json.spent_amount spent_amount
    end

    json.amounts do
      json.budget_amount do
        json.extract! @result.budget.budget_amount, :id, :value
      end
      json.spent_amount do
        json.value @result.spent_amount
      end
      json.currency do
        json.extract! @result.budget.budget_amount.currency, :id, :country, :country_code, :symbol
      end
    end

    json.associated_vendors do
      json.array!(sub_budget.budgetable_vendors) do |vendor|
        json.id vendor.id
        json.name vendor.name
      end
    end
    json.associated_categories do
      json.array!(sub_budget.budgetable_categories) do |category|
        json.id category.id
        json.name category.name
      end
    end
    json.associated_cost_centers do
      json.array!(sub_budget.budgetable_cost_centers) do |cost_center|
        json.id cost_center.id
        json.name cost_center.name
      end
    end
    json.associated_locations do
      json.array!(sub_budget.budgetable_locations) do |location|
        json.id location.id
        json.name location.name
      end
    end
    json.associated_departments do
      json.array!(sub_budget.budgetable_departments) do |department|
        json.id department.id
        json.name department.name
      end
    end
    json.associated_users do
      json.array!(sub_budget.budgetable_users) do |user|
        json.id user.id
        json.name user.name
      end
    end

    json.user do
      json.extract! sub_budget.user, :id, :mobile_number, :email
    end
  end
end


