class Expense::Personal::Unmark < Expense::Personal::Mark


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
      if selected_expense.user.balance_sheet.cash_in_hand < selected_expense.amount_value
        add_message :error, "You do not have enough cash on hand to unmark this expense as personal"
      end
    end
  end

  def process
    unless selected_expense.update(persona: false)
      add_message :error, selected_expense.errors.full_messages
    end
  end

  def post_process
    add_message :error, "Expense unmarked as personal"
  end
end