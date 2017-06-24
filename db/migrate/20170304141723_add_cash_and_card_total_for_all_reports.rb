class AddCashAndCardTotalForAllReports < ActiveRecord::Migration
  def up
    unless Report.count == 0
      Report.where(report_status_id: [ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]).each do |report|
        cash_total = report.total_amount(:only_cash_expenses)
        card_total = report.total_amount(:only_card_expenses)
        cash_total_amount = Amount.create(value: cash_total, currency: Currency.first)
        card_total_amount = Amount.create(value: card_total, currency: Currency.first)
        report.update(cash_expenses_total: cash_total_amount, card_expenses_total: card_total_amount)
      end
    end
  end

  def down
    Report.where(report_status_id: [ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]).each do |report|
      report.update(cash_expenses_total: nil, card_expenses_total: nil)
    end
  end
end
