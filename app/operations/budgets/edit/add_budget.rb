class Budgets::Edit::AddBudget < Budgets::Edit::Base

  def budget_modification_action
    :add_amount
  end

  def process
    new_amount = self.budget.amount_value + self.amount
    unless self.budget.amount.update(value: new_amount)
      add_message :error, self.budget.errors.full_messages
    end
  end
end