class Budgets::Update < Budgets::Base

  def init
    id = (params[:id] or params[:budget_id])
    self.budget = Budgets::Index.(user, params).budgets.with_id(id).first rescue nil

    self.budget_params = budget_params
  end

  def validate
    budgetables = budget_params[:budget_criteria_mappings_attributes]
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
  end

  def process
    if budget.update_attributes(self.budget_params)
      add_message :success, 'Successfully updated budget'
    else
      add_message :error, money_request.errors.full_messages
    end
  end

  def post_process
    add_message :error, "Successfully updated budget"
  end
end