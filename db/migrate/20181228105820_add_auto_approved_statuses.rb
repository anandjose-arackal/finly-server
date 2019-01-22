class AddAutoApprovedStatuses < ActiveRecord::Migration[4.2]
  def change
    ReportStatus.seed_data
    MoneyRequestStatus.seed_data
    TravelRequestStatus.seed_data
    BankPaymentRequestStatus.seed_data
  end
end
