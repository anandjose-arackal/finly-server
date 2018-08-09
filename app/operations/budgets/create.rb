class Budgets::Create < Budgets::Base
  attr_accessor :budgetable_types

  def init
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
    self.budget = user.company.budgets.build(budget_params)

    self.budget.user_id = user.id

    debugger

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