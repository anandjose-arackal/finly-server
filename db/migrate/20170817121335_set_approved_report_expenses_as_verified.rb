class SetApprovedReportExpensesAsVerified < ActiveRecord::Migration[4.2]
  def change
    ExpenseStatus.seed_data
    status_ids = [ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]
    ids = Report.all.with_status_id(status_ids).pluck(:id)
    Expense.with_report_id(ids).update_all(expense_status_id: ExpenseStatus.id_for(:verified))
  end
end
