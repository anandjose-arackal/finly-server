class BankPaymentRequestDrop < Drop

  def payments
    @object.payment_order.payments.map(&:to_liquid)
  end

end