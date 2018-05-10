class BankTransfer::PaymentRequest::ApiPayments::GetPaymentStatus < BankTransfer::PaymentRequest::Base

  attr_accessor :payment

  class BankTransfer::PaymentRequest::ApiPayments::GetPaymentStatus::PaymentPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    payment_order_ids = ::PaymentOrder.with_company_id(user.company_id).pluck(:id)
    self.payment = ::Payment.with_payment_order_id(payment_order_ids).find_by(id: id)
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment ID not found"
      return
    end
  end

  def success
    params[:payment] = self.payment
    BankTransfer::PaymentRequest::ApiPayments::GetPaymentStatus::PaymentPresenter.new(user, params, messages)
  end
end