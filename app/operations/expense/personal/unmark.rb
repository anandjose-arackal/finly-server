class Expense::Personal::Unmark < Expense::Personal::Mark

  attr_accessor :other_category_id

  def init
    super()
    self.other_category_id = user.categories.find_by(name: 'Other')
  end

  def validate
    unless selected_expense
      add_message :error, "Expense not found"
      return
    end

    unless selected_expense.personal
      add_message :error, "This is not a personal expense"
      return
    end

    unless selected_expense.unreported?
      add_message :error, "This expense cannot be edited at this stage"
      return
    end

    if selected_expense.card_expense?
      if selected_expense.user.balance_sheet.cash_in_hand&.value < selected_expense.amount_value
        add_message :error, "You do not have enough cash on hand to unmark this expense as personal"
      end
    end
  end

  def process
    unless selected_expense.update(personal: false, category_id: other_category_id)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    if selected_expense.card_expense?
      user.balance_sheet.subtract_cash_in_hand(selected_expense.amount_value)
    end
    add_message :success, "Expense unmarked as personal"
  end
end