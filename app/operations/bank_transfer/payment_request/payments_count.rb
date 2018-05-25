class BankTransfer::PaymentRequest::PaymentsCount < BankTransfer::PaymentRequest::Base

  attr_accessor :payments_count

  class BankTransfer::PaymentRequest::PaymentsCount::PaymentsCountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:payments_count]
    end

  end

  def init
    op = BankTransfer::PaymentRequest::Payments.(user, params)
    if op.success?
      self.payments_count = op.payments.count
    else
      self.payments_count = 0
    end
  end

  def success
    self.payments_count
  end

end