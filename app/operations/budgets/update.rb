class Budgets::Update < Budgets::Base

  attr_accessor :previous_values

  def init
    id = (params[:id] or params[:budget_id])
    self.budget = Budgets::Index.(user, params).budgets.find_by(id: id)

    self.budget_params = budget_params
  end

  def validate

    if self.budget.blank?
      add_message :error, "Budget not found"
      return
    end

    # budgetables = budget_params[:budget_criteria_mappings_attributes]
    # budgetables.each do |budgetable|
    #   unless ["Category", "CostCenter", "YesBankVendor", "Department", "Location", "User"].include?(budgetable[:budgetable_type])
    #     add_message :error, "Invalid criteria provided"
    #     return
    #   end
    # end
    #
    # budgetables.each do |budgetable|
    #   if budgetable[:budgetable_id].blank?
    #     add_message :error, "Criteria ID not provided"
    #     return
    #   end
    # end

    parent_budget = self.budget.parent
    # check to make sure the sum of all child budgets is less than the sum of all parent budgets
    if parent_budget.present?
      sum_of_child_budgets = parent_budget.children.without_id(self.budget.id).joins(:budget_amount).sum(:value)
      if (sum_of_child_budgets + budget_params&.dig(:budget_amount_attributes, :value)&.to_f) > parent_budget.budget_amount_value
        add_message :error, "Sum of child budgets should be less than or equal to parent budget"
        return
      end
    end
  end

  def pre_process
    self.previous_values = {
        name: self.budget.name,
        start_date: self.budget.start_date,
        end_date: self.budget.end_date,
        amount: self.budget.budget_amount&.value
    }
  end

  def process
    if budget.update_attributes(budget_params)
      add_message :success, 'Successfully updated budget'
    else
      add_message :error, money_request.errors.full_messages
    end
  end

  def post_process
    # add trail for budget updation
  end
end