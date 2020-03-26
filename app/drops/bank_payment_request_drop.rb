class BankPaymentRequestDrop < Drop

  def payments
    record.payment_order.payments.map(&:to_liquid)
  end

end