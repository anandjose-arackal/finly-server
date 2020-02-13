class MoveBudgetsToNewStructure < ActiveRecord::Migration[5.2]
  def change
    Budget.all.roots.each do |budget|
      budget_criteria_mappings = budget.budget_criteria_mappings

      # First creating the Budget Group from the Budget data - we can safely assume that each budget will be a
      # a different budget group for the time being
      budget_group = BudgetGroup.create(
          company_id: budget.company_id,
          period_id: budget.period_id,
          start_date: budget.start_date,
          end_date: budget.end_date,
          created_by_user_id: budget.user_id,
          expense: budget.expense,
          purchase_order: budget.purchase_order,
          purchase_request: budget.purchase_request,
          invoice: budget.purchase_order,
          payment: budget.payment
      )

      # extracting the criteria for this particular budget and then saving it in an object to
      # create the budget group criterium object
      mapping_attributes = []
      budget_criteria_mappings.each do |mapping|
        mapping_attributes << {
            budgetable_type: mapping.budgetable_type,
            budgetable_id: mapping.budgetable_id
        }
      end

      # creating the budget group criterium object
      # which will implicitly create all the individual budget objects
      parent_budget_group_criterium = BudgetGroupCriterium.create(
          budget_group_id: budget_group.id,
          created_by_user_id: budget.user_id,
          company_id: budget.company_id,
          budget_group_criteria_mappings_attributes: mapping_attributes
      )

      # now similarly for all the children of budgets we need to
      # create corresponding budget group criterium objects
      # that reflect the same structure as the budget
      budget.children.each do |child_budget|
        budget_criteria_mappings = child_budget.budget_criteria_mappings

        # extracting the criteria for this particular budget and then saving it in an object to
        # create the budget group criterium object
        mapping_attributes = []
        budget_criteria_mappings.each do |mapping|
          mapping_attributes << {
              budgetable_type: mapping.budgetable_type,
              budgetable_id: mapping.budgetable_id
          }
        end

        # creating the budget group criterium object
        # which will implicitly create all the individual budget objects
        budget_group_criterium = BudgetGroupCriterium.create(
            parent_id: parent_budget_group_criterium.id,
            budget_group_id: budget_group.id,
            created_by_user_id: budget.user_id,
            company_id: budget.company_id,
            budget_group_criteria_mappings_attributes: mapping_attributes
        )
      end
    end
  end
end
