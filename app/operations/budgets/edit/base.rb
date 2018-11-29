class Budgets::Edit::Base < Budgets::Base

  attr_accessor :budget, :amount

  def pre_validate
    super
    if params[:amount].blank?
      add_message :error, "Please enter an amount to add or subtract to the budget"
    end
  end

  def init
    id = params[:id] || params[:budget_id]
    self.budget = user.company.budgets.find_by(id: id)
    self.amount = params[:amount]
  end

  def validate
    if self.budget.blank?
      add_message :error, "Budget not found"
      return
    end
  end

  def budget_modification_action

  end

  def post_process
    # creating the trail for this budget modification
    budget.budget_modificaion_trails.build(action_user_id: user.id,
                                           action_id: BudgetModificationAction.id_for(budget_modification_action),
                                           current_value: self.budget.amount_value).save

    add_message :success, "Budget successfully modified"
  end

end