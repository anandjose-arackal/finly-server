class Budgets::Create < Budgets::Base
  attr_accessor :budgetable_types

  def init
    self.budget_params = budget_params
  end

  def validate
    budgetables = budget_params[:budget_criteria_mappings_attributes]

    if budget_params[:budget_amount_attributes].blank?
      add_message :error, "Please specifiy the budget amount."
      return
    end

    if budgetables.blank?
      add_message :error, "Budget criteria details needs to be specified."
      return
    end

    budgetables.each do |budgetable|
      unless ["Category", "CostCenter", "YesBankVendor", "Department", "Location", "User"].include?(budgetable[:budgetable_type])
        add_message :error, "Invalid criteria provided"
        return
      end
    end

    budgetables.each do |budgetable|
      if budgetable[:budgetable_id].blank?
        add_message :error, "Criteria ID not provided"
        return
      end
    end

    valid_date = Date.parse(budget_params[:start_date]) rescue false 
    unless valid_date
        add_message :error, 'Invalid start date provided'
        return
    end

    valid_date = Date.parse(budget_params[:end_date]) rescue false 
    unless valid_date
        add_message :error, 'Invalid end date provided'
        return
    end

    # this logic expects first to update the parent and then the child, if
    # budget of child exceeds that of its parent
    parent_budget_id = budget_params[:parent_id]
    parent_budget = user.company.budgets.find_by(id: parent_budget_id)
    # check to make sure the sum of all child budgets is less than the sum of all parent budgets
    if parent_budget.present?
      unless parent_budget.start_date <= Date.parse(budget_params[:start_date])
        add_message :error, "Start date for this budget should be after the start date(#{parent_budget.start_date.strftime("%d-%m-%Y")}) for the selected parent budget."
        return
      end

      unless parent_budget.end_date >= Date.parse(budget_params[:end_date])
        add_message :error, "End date for this budget should be earlier than the end date(#{parent_budget.end_date.strftime("%d-%m-%Y")}) for the selected parent budget."
        return
      end

      # sums of all child budgets EXCEPT the budget we are processing now in this op
      sum_of_child_budgets = parent_budget.children.joins(:budget_amount).sum(:value)
      if (sum_of_child_budgets + budget_params&.dig(:budget_amount_attributes, :value)&.to_f) > parent_budget.budget_amount&.value
        add_message :error, "Sum of child budgets should be less than or equal to parent budget(#{parent_budget.budget_amount.currency.symbol.to_s + parent_budget.budget_amount.value.to_s})"
        return
      end
    end
  end


  def process
    self.budget = user.company.budgets.build(budget_params)

    self.budget.user_id = user.id

    if budget.valid?
      budget.save
    else
      add_message :error, budget.errors.full_messages
    end
  end

  def post_process
    add_message :success, 'Successfully created budget'
  end
end