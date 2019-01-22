class AddReportToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_reference :expenses, :report, index: true, foreign_key: true
  end
end
