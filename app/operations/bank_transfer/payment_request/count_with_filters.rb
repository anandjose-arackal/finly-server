class BankTransfer::PaymentRequest::CountWithFilters < BankTransfer::PaymentRequest::Base

  attr_accessor :count

  def init

  end

  def process
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.count = op.payment_requests&.count rescue 0
    else
      self.count = 0
    end
  end

  def success
    params[:count] = self.count
    BankTransfer::PaymentRequest::CountWithFiltersPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::CountWithFiltersPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end
end
