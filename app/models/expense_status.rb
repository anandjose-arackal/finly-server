class ExpenseStatus < ActiveRecord::Base


  # delegated from expense model
  def expense_status
    self.name
  end
end
