class Expense::Manual::Duplicate::ProcessDuplicate < Expense::Base
  attr_accessor :expense

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:expense].blank?
      add_message :error, 'Expense not found'
      return
    end
  end

  def init
    self.expense = params[:expense]
  end

  def validate
    if self.expense.blank?
      add_message :error, 'Expense not found'
      return
    end
  end

  def process
    old_duplicates = expense.duplicate_expenses
    old_duplicate_ids = old_duplicates.pluck(:id) - [expense.id]
    new_duplicates = Expense.with_date(expense.date).having_amount_currency(expense.amount.value, expense.amount.currency_id)
    new_duplicate_ids = new_duplicates.pluck(:id) - [expense.id]

    duplicates_to_create = new_duplicate_ids - old_duplicate_ids
    duplicates_to_destroy = old_duplicate_ids - new_duplicate_ids

    # Destroy old duplicates which are not duplicates anymore
    DuplicateExpenseMapping.expense_with_duplicates(expense.id, duplicates_to_destroy).destroy_all

    # Create duplicates which are duplicates
    new_mappings = []
    duplicates_to_create.each do |exp_id|
      new_mappings << {expense_id: expense.id, duplicate_expense_id: exp_id}
      new_mappings << {expense_id: exp_id, duplicate_expense_id: expense.id}
    end
    DuplicateExpenseMapping.create new_mappings
  end

end