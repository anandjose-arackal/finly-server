class BudgetManager::BudgetGroupCriteria::AsyncBudgetsCreator < Transactions::API

  include Events::Consumer

  # consumes_event! 'budget_group_criteria.create'

  def work(user, payload)
    self.class.(params: payload, current_user: user)
  end

  step :create_all_related_budgets!

  def create_all_related_budgets!(options, params:, **)
    budget_group_criteria = params[:record]
    budget_group = budget_group_criteria.budget_group
    start_date = budget_group_criteria.budget_group.start_date
    final_end_date = budget_group_criteria.budget_group.end_date
    while start_date < final_end_date do
      end_date = BudgetManagerUtils.next_date(start_date, final_end_date, budget_group_criteria.budget_group.period_id)
      break if end_date.blank?
      budget = budget_group_criteria.budgets.build(
          start_date: start_date,
          end_date: end_date,
          name: "#{start_date.strftime("%d %B, %Y")} - #{end_date.strftime("%d %B, %Y")}",
          company_id: budget_group_criteria.company_id,
          budget_group_id: budget_group_criteria.budget_group.id,
          user_id: budget_group_criteria.budget_group.created_by_user_id,
          budget_date_type_id: budget_group_criteria.budget_group.budget_date_type_id,
          calculated_before_tax_amount: budget_group_criteria.budget_group.calculated_before_tax_amount,
          budget_amount_attributes: {
              value: 0,
              currency_id: 1
          }
      )
      budget.save

      # now setting the start date as the next day of the end date
      start_date = end_date + 1.day
    end
    true
  end

end