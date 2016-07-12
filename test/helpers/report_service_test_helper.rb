module ReportServiceTestHelper

  def add_dummy_expenses(user, report)
    report_service = ReportService.new(user: user, report: report)
    expense_service = ExpenseService.new(user)
    expenses = []
    expenses_ids = []
    5.times.each do
      e = expense_service.add_expense(expense: {amount: Faker::Commerce.price, merchant: Faker::Company.name, expense_status_id: 1,
                                                expense_type_id: 1, date: Date.today, currency_id: 1})
      expenses << e
      expenses_ids << e.id
    end
    expenses = user.expenses.where(id: expenses_ids)
    report_service.add_expense(expenses)
  end

end