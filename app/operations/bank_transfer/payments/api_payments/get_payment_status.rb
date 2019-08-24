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
    case params[:search_type]
      when 'id'
        self.payment = ::Payment.with_company_id(user.company_id).with_id(id).first
      when 'external_id'
        self.payment = ::Payment.with_company_id(user.company_id).with_external_id(id).first
      else
        self.payment = ::Payment.with_company_id(user.company_id).with_id(id).first
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