class TaxBenefitProcess

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    scheduled_payment_orders = PaymentOrder.from_disburse.scheduled_on_or_before(Date.today)
    scheduled_payment_orders.each do |order|
      Benefits::TaxBenefits::Execute.call(order.initiating_user, payment_order_id: order.id)
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end