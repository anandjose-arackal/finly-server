# this operation will take a payment order id and return whether the particular order can
# be processed at the current time or not - can return a flag, or the actual timings as well

class BankTransfer::Configuration::TransferTimings < BankTransfer::Configuration::Base

  attr_accessor :timings, :payment_order, :payment_request

  class BankTransfer::Configuration::TransferTimings::TimingsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :timings, :allowed, :next_valid_date

    def init
      self.allowed = params[:allowed]
      self.timings = params[:timings]
      self.next_valid_date = params[:next_date]
    end

  end

  def pre_validate

  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = payment_request.payment_order
  end

  def validate
    if self.payment_request.blank? || self.payment_order.blank?
      add_message :error, "Payment order not found"
    end
  end

  def process

  end

  def success
    params[:allowed] = TransferTimingUtils.within_timeframe?(payment_order.payment_mode)
    params[:next_date] = TransferTimingUtils.next_valid_date(DateUtils.local_date_time, payment_order.payment_mode)
    BankTransfer::Configuration::TransferTimings::TimingsPresenter.new(user, params, messages)
  end

end