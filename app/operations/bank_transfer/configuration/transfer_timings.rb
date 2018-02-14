# this operation will take a payment order id and return whether the particular order can
# be processed at the current time or not - can return a flag, or the actual timings as well

class BankTransfer::Configuration::TransferTimings < BankTransfer::Configuration::Base

  attr_accessor :timings, :payment_order, :payment_request, :payment_mode, :date,
                :payment_requests, :payment_orders, :payment_modes,
                :non_processable_requests, :processable_requests,
                :allowed

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
    if id.present?
        init_bank_payment_request(id)
    else
      self.payment_mode = params[:payment_mode]
      self.date = params[:date]
    end
    self.processable_requests = self.non_processable_requests = []
  end

  def validate
    id = params[:id] || params[:bank_payment_request_id]
    if id.present? and self.payment_requests.blank? && self.payment_orders.blank?
      add_message :error, 'Payment order not found'
      return
    end
    if self.payment_mode.blank? && self.payment_modes.blank?
      add_message :error, 'Payment mode cannot be blank'
      return
    end
  end

  def process
    self.allowed = true
    self.payment_orders.each do |order|
      status = TransferTimingUtils.within_timeframe?(order.payment_mode)
      if status
        self.processable_requests << order.bank_payment_request&.id
      else
        self.non_processable_requests << order.bank_payment_request&.id
        self.allowed = false
      end
    end
  end

  def success
    params[:allowed] = self.allowed
    params[:next_date] = TransferTimingUtils.next_valid_date(self.date, self.payment_mode)
    BankTransfer::Configuration::TransferTimings::TimingsPresenter.new(user, params, messages)
  end

  protected

  def init_bank_payment_request(id)
    self.payment_requests = BankPaymentRequest.with_id(id)
    self.payment_order = PaymentOrder.with_id(self.payment_requests.pluck(:payment_order_id))
    self.date = payment_order&.scheduled_at
    self.payment_mode = payment_order&.payment_mode
  end

end