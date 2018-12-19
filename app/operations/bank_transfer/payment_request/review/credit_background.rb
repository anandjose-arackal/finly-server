class BankTransfer::PaymentRequest::Review::CreditBackground < BackgroundOperation
  sidekiq_options queue: :payments_queue

  attr_accessor :payment_requests, :options, :initiating_user

  def self.call(payment_request_ids, options = {})
    self.new.perform(payment_request_ids, options)
  end

  def perform(payment_request_ids, options, request_store_hash = nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_requests = BankPaymentRequest.where(id: payment_request_ids)
    self.options = options
    self.run
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate

  end

  def init

  end

  def validate
    # todo - validations for the background process that will credit these payment orders
    
  end

  def pre_process
    # set the status of these payment orders as scheduled
  end

  def process
    self.payment_requests.each do |payment_request|
      order = payment_request.payment_order
      op = BankTransfer::YesBank::Execute.call(order.initiating_user, payment_order_id: order.id)
    end
  end
end