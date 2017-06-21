class Expense::Show < Expense::Base

  def pre_validate
    super
    if params[:expense_id].blank? or params[:id].blank?
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

end