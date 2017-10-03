# this operation will retry an individual payment that has failed for any reason
# the retry is instant - as in, even scheduled payments will be retried instantly

class BankTransfer::Payments::Retry < BankTransfer::Payments::Base

  attr_accessor :payment, :payment_order

  def self.call(payment, options = {})
    payment_id = payment
    if payment_id.present? and payment_id.is_a?(Payment)
      payment_id = payment_id.id
    end
    self.new.perform(payment_id, options)
  end

  def self.call_async(payment_id, options = {})
    # define the operation to accordingly run the operation in the background
    self.perform_async(payment_id, options)
  end

  def perform(payment_id, options)
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment = Payment.unscoped.find_by_id(payment_id)
    self.options = options
    self.run
  end

  def perform_async(payment_id, options)
    # in case the object is passed directly instead of an id
    payment_id = payment_id
    if payment_id.present? && payment_id.is_a?(PaymentOrder)
      payment_id = payment_id.id
    end
    # calls the Sidekiq::Worker method
    super(payment_id, options)
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate
    if self.payment.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def init
    self.payment_order = self.payment.payment_order
  end

  def validate
    unless payment.failed?
      add_message :error, "Only failed payments can be retried"
      return
    end

    unless payment.payment_order.present?
      add_message :error, "This payment does not belong to a payment order"
      return
    end
  end

  def pre_process
    # changing the status of the payment as pending
    payment.update(payment_status_id: PaymentStatus.id_for(:pending))
  end

  def process
    # calling payment executor so that the payment can be successfully executed using the respective adapters
    op = AccountManager::Payments::PaymentExecutor.(self.payment)
    if op.success?
      if self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:completed)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
      elsif self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:failed)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      else
        # this is partially completed
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      end
    else
      # no change in the payment order or payment anyway. So do nothing?
    end
  end

  def post_process
    add_message :success, "Payment retry successfully executed"
  end

end