class BankPaymentRequestExposure < Exposures::API

  def payments
    record.payment_order.payments.map(&:to_exposure)
  end

end