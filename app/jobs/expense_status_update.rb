class ExpenseStatusUpdate < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name}  at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    report_ids =[]
    report_status =["Approved","Settled","Settlement Confirmed", "Closed","settlement_confirmed", "auto_approved"]
    report_ids << report_status.map{|status| ReportStatus.id_for(status.downcase)}
    Expense.where('expense_status_id != ?',ExpenseStatus.id_for(:verified)).joins(:report).where(reports: {report_status_id: report_ids}).update_all(expense_status_id: ExpenseStatus.id_for(:verified))

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end
end