class Expense::Show < Expense::Base
  attr_accessor :expense

  def init
    id = (params[:expense_id] or params[:id])

    if params[:normal_key_sent]
      if ExpenseShowFasterLookupToggle.new(user).enabled?
        self.expense = Expense.find_by id: id
      else
        self.expense = Expense::Index.(user, params)&.expenses&.find_by(id: id)
      end
    else
      if ExpenseShowFasterLookupToggle.new(user).enabled?
        self.expense = Expense.find_by uuid_key: id
      else
        self.expense = Expense::Index.(user, params)&.expenses&.find_by(uuid_key: id)
      end
    end



  end

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

end