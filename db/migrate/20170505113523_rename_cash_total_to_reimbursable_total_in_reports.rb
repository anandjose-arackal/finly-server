class RenameCashTotalToReimbursableTotalInReports < ActiveRecord::Migration
  def change
    rename_column :reports, :cash_expenses_total_id, :reimbursable_expenses_total_id
    add_column :reports, :non_reimbursable_expenses_total_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
