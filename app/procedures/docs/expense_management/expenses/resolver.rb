class Docs::ExpenseManagement::Expenses::Resolver < Resolver::API

  entity Expense

  # Todo - this was quickly implemented for macros. This is not thought through well and might require a re-write
  # Currently this will only return company expenses or personal expenses
  def load(params)
    expenses = nil
    if user.admin?(:em)
      expenses = Expense.where(company_id: user.company_id)
    else
      expenses = user.expenses
    end

    expenses
  end


end