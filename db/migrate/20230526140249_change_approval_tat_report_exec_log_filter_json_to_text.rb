class ChangeApprovalTatReportExecLogFilterJsonToText < ActiveRecord::Migration[6.0]
  def change
    change_column :approval_tat_report_exec_logs, :filter_json, :text
  end
end
