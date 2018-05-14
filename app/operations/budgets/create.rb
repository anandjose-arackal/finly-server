class Budgets::Create < Budgets::Base
  attr_accessor :budgetable_types

  def init
    self.budget_params = create_budget_params

    self.budgetable_types = %w( User YesBankVendor Category FieldDropDownItem )

  end

  def validate
    budgetable_type = budget_params[:budgetable_type]
    unless budgetable_types.include?(budgetable_type)
      add_message :error, 'Invalid budget association provided'
      return
    end

    if budget_params[:budgetable_id].blank?
      add_message :error, 'Invalid budget association provided'
      return
    end

    budgetable = budgetable_type.constantize.with_id budget_params[:budgetable_id]
    unless budgetable.present?
      add_message :error, "#{budgetable_type} not found"
    end

  end

  def process
    self.budget = user.company.budgets.build(budget_params)

    self.budget.user_id = user.id

    unless budget.valid?
      add_message :error, budget.errors.full_messages
    else
      budget.save
    end
  end

  def post_process
    add_message :success, 'Successfully created budget'
  end

end