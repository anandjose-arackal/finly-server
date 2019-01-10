class RenamePartialCompleteToPartiallyCompleted < ActiveRecord::Migration[4.2]
  def change
    if PaymentOrderStatus.count > 0 and PaymentOrderStatus.with_name('partial_complete').present?
      PaymentOrderStatus.with_name('partial_complete').first.update(name: 'partially_completed')
    end
  end
end
