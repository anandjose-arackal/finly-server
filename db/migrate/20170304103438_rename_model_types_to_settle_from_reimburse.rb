class RenameModelTypesToSettleFromReimburse < ActiveRecord::Migration
  def up
    # ReportStatus.find(6).update(name: "Settled")
    # ReportStatus.find(7).update(name: "Settlement Confirmed")
    #
    # ReportCommentAction.find(11).update(name: "report_settled")
    # ReportCommentAction.find(12).update(name: "report_settlement_confirmed")
    #
    # NotifierType.find(9).update(name: "report_settled")
  end

  def down
    ReportStatus.find(6).update(name: "Reimbursed")
    ReportStatus.find(7).update(name: "Reimbursement Confirmed")

    ReportCommentAction.find(11).update(name: "report_reimbursed")
    ReportCommentAction.find(12).update(name: "report_reimbursement_confirmed")

    NotifierType.find(9).update(name: "report_reimbursed")
  end
end
