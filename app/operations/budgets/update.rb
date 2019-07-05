class Budgets::Update < Budgets::Base

  attr_accessor :previous_values, :budget_parameters

  def init
    id = (params[:id] or params[:budget_id])
    params[:include_children] = true
    self.budget = Budgets::Index.(user, params).budgets.find_by(id: id)

    self.budget_parameters = budget_params
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

    if budget_params[:budget_amount_attributes].blank?
      add_message :error, "Please specifiy the budget amount."
      return
    end

    if !!budget_params[:start_date] or !!budget_params[:end_date]
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
    end

    if params.dig(:budget, :type)
      # on a temp basis based on design, support increase and reduction of budgets
      case params[:budget][:type]
      when 'increase'
        self.budget_parameters[:budget_amount_attributes][:value] = ((self.budget.budget_amount&.value).to_f + (self.budget_parameters[:budget_amount_attributes][:value]).to_f) rescue self.budget.budget_amount&.value
      when 'reduce'
        self.budget_parameters[:budget_amount_attributes][:value] = ((self.budget.budget_amount&.value).to_f - (self.budget_parameters[:budget_amount_attributes][:value]).to_f) rescue self.budget.budget_amount&.value
      end

      if self.budget_parameters[:budget_amount_attributes][:value].to_f < 0
        add_message :error, "Budget amount cannot be less than 0."
        return
      end

      params[:budget].delete(:type)
    end

    # this logic expects first to update the parent and then the child, if
    # budget of child exceeds that of its parent
    parent_budget = self.budget.parent
    # check to make sure the sum of all child budgets is less than the sum of all parent budgets
    if parent_budget.present?
      if !!budget_params[:start_date] or !!budget_params[:end_date]
        unless parent_budget.start_date <= Date.parse(budget_params[:start_date])
          add_message :error, "Start date for this budget should be after the start date for the selected parent budget."
          return
        end

        unless parent_budget.end_date >= Date.parse(budget_params[:end_date])
          add_message :error, "End date for this budget should be earlier than the end date for the selected parent budget."
          return
        end
      end

      # sums of all child budgets EXCEPT the budget we are processing now in this op
      sum_of_child_budgets = parent_budget.children.without_id(self.budget.id).joins(:budget_amount).sum(:value) 
      if (sum_of_child_budgets + budget_parameters&.dig(:budget_amount_attributes, :value)&.to_f) > parent_budget.budget_amount&.value
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
    if budget.update_attributes(budget_parameters)
      add_message :success, 'Successfully updated budget'
    else
      add_message :error, budget.errors.full_messages
    end
  end

  def post_process
    # add trail for budget updation
  end
end