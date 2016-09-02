class Expense::Show < Expense::Base

  def authorize
    if self.expense.blank?
      errors << 'Expense not found'
      raise_unauthorized_exception
    end
  end

end