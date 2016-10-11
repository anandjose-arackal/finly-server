class AddReportToExpenses < ActiveRecord::Migration
  def change
    add_reference :expenses, :report, index: true, foreign_key: true
  end
end
