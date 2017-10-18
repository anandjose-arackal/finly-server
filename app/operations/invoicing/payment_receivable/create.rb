class Invoicing::PaymentReceivable::Create < Invoicing::PaymentReceivable::Base

  attr_accessor :payment_receivable, :payment_receivable_params

  def init
    self.payment_receivable_params = receivable_params
  end

  def process

  end

  private

  def receivable_params

  end
end