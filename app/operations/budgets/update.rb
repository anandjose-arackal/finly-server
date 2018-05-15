class Budgets::Update < Budgets::Base

  def pre_validate

  end

  def init
    id = (params[:id] or params[:budget_id])
    self.budget = Budgets::Index.(user, params).budgets.with_id(id).first rescue nil

    self.budget_params = update_budget_params
  end

  def validate
    if self.budget.blank?
      add_message :error, 'Budget not found'
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
  end
end