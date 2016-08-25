module ReportOperationTestHelper

  # adds dummy expenses to a report and returns the report
  def add_dummy_expenses(user, report, amount = nil)
    expense_params = {expense: {amount: 100,
                                 merchant: "Olacabs",
                                 note: "Sup dawg",
                                 expense_status_id: 1,
                                 expense_type_id: 1,
                                 date: Date.today,
                                 currency_id: 1,
                                 category_id: 1 }
    }
    expense_ids = []
    # creating 5 dummy expenses for this user
    5.times do
      expense = Expense::Manual::Create.new(user, expense_params).run
      expense_ids << expense.id
    end

    report = Report::Create.new(user, expense_ids: expense_ids).run
    return report
  end
end