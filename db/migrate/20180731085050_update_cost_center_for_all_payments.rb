class UpdateCostCenterForAllPayments < ActiveRecord::Migration[4.2]
  def change
    Payment.all.each do |payment|
      invoice = payment.invoice
      if invoice.present?
        payment.update(cost_center_id: invoice.cost_center_id)
      end
    end
  end
end