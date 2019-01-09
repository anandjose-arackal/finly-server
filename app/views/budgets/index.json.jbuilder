json.result do
  json.array! @result.paginated_budgets do |budget|
    json.extract! budget, :id, :name
    # json.period do
    #   json.extract! budget.period, :id, :name
    # end

    json.start_date budget.start_date&.strftime("%d-%b-%y")
    json.end_date budget.end_date&.strftime("%d-%b-%y")

    json.budget_amount do
      json.extract! budget.budget_amount, :id, :value, :currency_id
    end

    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    json.spent_amount do
      json.value processor_instance.spent_amount
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
      json.extract! budget.user, :id, :mobile_number, :email
    end

    json.sub_budgets do
      json.array!(budget.budget_children) do |sub_budget|
        json.extract! sub_budget, :id, :name

        json.start_date sub_budget.start_date&.strftime("%d-%b-%y")
        json.end_date sub_budget.end_date&.strftime("%d-%b-%y")

        json.budget_amount do
          json.extract! sub_budget.budget_amount, :id, :value, :currency_id
        end

        processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(sub_budget)
        json.spent_amount do
          json.value processor_instance.spent_amount
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
  end
end

json.count @result.count
