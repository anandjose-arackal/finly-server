class UpdateCostCenterForAllPayments < ActiveRecord::Migration
  def change
    Payment.all.each do |payment|
      invoice = payment.invoice
      if invoice.present?
        payment.update(cost_center_id: invoice.cost_center_id)
      end
    end
  end
end