class Procurements::Payments::Show < Procurements::Payments::Base
  attr_accessor :payment, :company

  class Procurements::Payments::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment, :vendor, :bank_payment_request

    def init
      self.payment = params[:payment]
      self.bank_payment_request = payment&.payment_order&.bank_payment_request
      self.vendor = payment.receiving_user
    end
  end

  def init
    self.company = user.company
    payment_id = params[:id] || params[:payment_id]
    self.payment = Payment.find_by id: payment_id
  end

  def validate
    unless self.payment.present?
      add_message :error, 'Payment not found'
    end
  end

  def success
    params[:payment] = self.payment
    Procurements::Payments::Show::ShowPresenter.new(user, params, messages)
  end
end