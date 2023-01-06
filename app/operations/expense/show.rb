class Expense::Show < Expense::Base
  attr_accessor :expense

  def pre_validate
    super
    if params[:expense_id].blank? && params[:id].blank?
      add_message :error, 'Expense not found'
      return
    end
  end

  def validate
    super
    if self.expense.blank?
      add_message :error, 'Expense not found'
      return
    end
  end

  def process
    expense = user.expenses.find_by params[:expense_id]
  end

end