class ChangeOrderOfReportStatus < ActiveRecord::Migration[4.2]
  def change
    if ReportStatus.count > 0
      processing = ReportStatus.with_name('Processing').first rescue nil
      retracted = ReportStatus.with_name('Retracted').first rescue nil

      if processing&.order == 2
        processing.update(order: 3)
      end
      if retracted&.order == 3
        retracted.update(order: 2)
      end
    end
    add_column :money_request_statuses, :order, :integer, null: false, default: 1
    if MoneyRequestStatus.count > 0
      MoneyRequestStatus.all.each do |status|
        status.update(order: MoneyRequestStatus.order_for_id(status.id))
      end
    end
  end
end
