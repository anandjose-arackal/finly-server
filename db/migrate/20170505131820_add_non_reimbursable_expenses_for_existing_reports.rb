class AddNonReimbursableExpensesForExistingReports < ActiveRecord::Migration[4.2]
  def change
    unless Report.count == 0
      Report.approved.all.each do |report|
        non_reimbursable_amount = report.expenses.only_card_expenses.joins(:amount).sum(:value)
        report.update(non_reimbursable_expenses_total_attributes: {value: non_reimbursable_amount, currency: Currency.first})
      end
    end
  end
end
