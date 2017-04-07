class RenamePendingReimbursementToApprivedReportsTotal < ActiveRecord::Migration
  def change
    rename_column :balance_sheets, :pending_reimbursement_id, :approved_reports_total_id
  end
end
