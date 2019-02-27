class BankTransfer::Payments::ApiPayments::GetPaymentStatus < BankTransfer::Payments::Base

  attr_accessor :payment

  class BankTransfer::Payments::ApiPayments::GetPaymentStatus::PaymentPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    payment_order_ids = ::PaymentOrder.with_company_id(user.company_id).pluck(:id)
    self.payment = ::Payment.with_payment_order_id(payment_order_ids).find_by(id: id)
    # if the payment is still not found, check with the external ID
    if self.payment.blank?
      self.payment = ::Payment.with_payment_order_id(payment_order_ids).find_by(external_reference_id: id)
    end
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment ID not found"
      return
    end
  end

  def success
    params[:payment] = self.payment
    BankTransfer::Payments::ApiPayments::GetPaymentStatus::PaymentPresenter.new(user, params, messages)
  end
end