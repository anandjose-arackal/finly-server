class ExpenseType < ActiveRecord::Base

  # delegated from expense model
  def expense_type
    self.name
  end

end
