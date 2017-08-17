class SetApprovedReportExpensesAsVerified < ActiveRecord::Migration
  def change
    ExpenseStatus.seed_data
    ids = Report.all.with_status_id(ReportStatus.ids_for([:approved, :settled, :settlement_confirmed, :closed])).pluck(:id)
    Expense.with_report_id(ids).update_all(expense_status_id: ExpenseStatus.id_for(:verified))
  end
end
