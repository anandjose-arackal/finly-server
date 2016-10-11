module ReportOperationTestHelper

  # adds dummy expenses to a new report and returns the report. optional amount if the report total needs to be a certain amount
  def create_report(user, amount = nil)
    expense_params = {expense: {amount: 90,
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
    if amount
      (amount/100).to_i.times do
        expense = Expense::Manual::Create.new(user, expense_params).run
        expense_ids << expense.id
      end
    else
      5.times do
        expense = Expense::Manual::Create.new(user, expense_params).run
        expense_ids << expense.id
      end
    end

    report = Report::Create.new(user, expense_ids: expense_ids).run
    return report
  end
end