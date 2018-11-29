class Budgets::Edit::ReduceBudget < Budgets::Edit::Base

  def budget_modification_action
    :reduce_amount
  end

  def validate
    super
    if self.amount >= self.budget.amount_value
      add_message :error, "You cannot reduce an amount greater than the budget amount"
      return
    end
  end

  def process
    new_amount = self.budget.amount_value - self.amount
    unless self.budget.amount.update(value: new_amount)
      add_message :error, self.budget.errors.full_messages
    end
  end

end