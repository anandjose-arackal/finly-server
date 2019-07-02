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

    parent_budget_id = params[:parent_id]
    parent_budget = user.company.budgets.find_by(id: parent_budget_id)
    # check to make sure the sum of all child budgets is less than the sum of all parent budgets
    if parent_budget.present?
      sum_of_child_budgets = parent_budget.children.joins(:budget_amount).sum(:value)
      if (sum_of_child_budgets + budget_params&.dig(:budget_amount_attribtues, :value)&.to_f) > parent_budget.budget_amount_value
        add_message :error, "Sum of child budgets should be less than or equal to parent budget"
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