class ChangeAutoApprovedFlagToStatus < ActiveRecord::Migration[5.2]
  def change
    Report.where(auto_approve: true, report_status_id: ReportStatus.id_for(:approved)).update_all(report_status_id: ReportStatus.id_for(:auto_approved))
    BankPaymentRequest.where(auto_approved: true, status_id: BankPaymentRequestStatus.id_for(:approved)).update_all(status_id: BankPaymentRequestStatus.id_for(:auto_approved))
    MoneyRequest.where(auto_approve: true, status_id: MoneyRequestStatus.id_for(:approved)).update_all(status_id: MoneyRequestStatus.id_for(:auto_approved))
  end
end
