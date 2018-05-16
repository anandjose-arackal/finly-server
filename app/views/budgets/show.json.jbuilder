json.extract! @result.budget, :id, :name, :budgetable_id, :budgetable_type
# json.period do
#   json.extract! @result.budget.period, :id, :name
# end

json.start_date @result.budget.start_date&.strftime("%d-%b-%y")
json.end_date @result.budget.end_date&.strftime("%d-%b-%y")

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
  json.array! @result.budget_trail_items do |item|
    json.extract! item, :id, :date
    json.amount do
      json.value item.amount.value
      json.currency do
        json.extract! item.amount.currency, :id, :country, :country_code, :symbol
      end
    end

    if item.class.name == 'Expense'
      json.status item.expense_status.name.humanize
      json.expense_type item.expense_type.name.humanize + " Expense"
      json.type "expense"
      json.user do
        json.extract! item.user, :id, :name, :email, :mobile_number
      end

    elsif item.class.name == 'Payment'
      json.status item.payment_status.name.humanize
      json.type "payment"
      json.vendor do
        json.extract! item.receiving_user, :id, :name, :email, :mobile_number
      end

      json.initiating_user do
        json.extract! item.initiating_user, :id, :name, :email, :mobile_number
      end

    end
  end
end

json.associated_item do
  json.id @result.budget.budgetable_id
  json.type @result.budget.budgetable_type
  json.item @result.budget.budgetable
end

json.user do
  json.extract! @result.budget.user, :id, :mobile_number, :email
end


