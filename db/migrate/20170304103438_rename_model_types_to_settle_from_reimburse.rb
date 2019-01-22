class RenameModelTypesToSettleFromReimburse < ActiveRecord::Migration[4.2]
  def up
    status_count = ReportStatus.count
    ReportStatus.find(6).update(name: "Settled") if status_count > 5
    ReportStatus.find(7).update(name: "Settlement Confirmed") if status_count > 6

    action_count = ReportCommentAction.count
    ReportCommentAction.find(11).update(name: "report_settled") if action_count > 10
    ReportCommentAction.find(12).update(name: "report_settlement_confirmed") if action_count > 11

    type_count = NotifierType.count
    NotifierType.find(9).update(name: "report_settled") if type_count > 8
  end

  def down
    status_count = ReportStatus.count
    ReportStatus.find(6).update(name: "Reimbursed") if status_count > 5
    ReportStatus.find(7).update(name: "Reimbursement Confirmed") if status_count > 6

    action_count = ReportCommentAction.count
    ReportCommentAction.find(11).update(name: "report_reimbursed") if action_count > 10
    ReportCommentAction.find(12).update(name: "report_reimbursement_confirmed") if action_count > 11

    type_count = NotifierType.count
    NotifierType.find(9).update(name: "report_reimbursed") if type_count > 8
  end
end
