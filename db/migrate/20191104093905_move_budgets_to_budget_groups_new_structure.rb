class MoveBudgetsToBudgetGroupsNewStructure < ActiveRecord::Migration[5.2]
  def change
    # TODO - temporarily commenting this so that it can be changed later
    
    # Budget.all.each do |budget|
    #   budget_criteria_mappings = budget.budget_criteria_mappings
    #   mapping_attributes = []
    #   budget_criteria_mappings.each do |map|
    #     mapping_attributes << {
    #         budgetable_type: map.budgetable_type,
    #         budgetable_id: map.budgetable_id
    #     }
    #   end
    #   budget_group = BudgetGroup.new(
    #                     company_id: budget.company_id,
    #                     period_id: budget.period_id,
    #                     created_by_user_id: budget.user_id,
    #                     purchase_order: budget.purchase_order,
    #                     invoice: budget.invoice,
    #                     purchase_request: budget.purchase_request,
    #                     expense: budget.expense,
    #                     payment: budget.payment,
    #                     budget_group_criteria_mappings_attributes: mapping_attributes
    #   )
    #   budget_group.save
    #   budget.update_columns(budget_group_id: budget_group.id)
    #
    #   # todo - budget consumption model will be updated once the operation is implemented in TRB
    # end
  end
end
