# will retry a single payment synchronously when requested

class AccountManager::Payments::RetryPaymentBackground < AccountManager::Base

  attr_accessor :payment, :payment_order, :payment_mode, :options

  def initialize
    # self.payment = payment
    # self.payment_mode = options[:payment_mode]
  end

  def self.call(payment, options)
    payment_id = payment
    if payment_id.present? and payment_id.is_a?(Payment)
      payment_id = payment_id.id
    end
    self.new.perform(payment_id, options)
  end

  def perform(payment_id, options, request_store_hash=nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment = Payment.unscoped.find_by_id(payment_id)
    self.options = options
    self.run
  end

  def init
    self.payment_order = payment.payment_order
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
    # clearing the system messages for this particular payment
    self.payment.system_messages.destroy_all
    # changing the status of the payment as pending
    payment.update(payment_status_id: PaymentStatus.id_for(:pending))
  end

  def process
    # first update the payment order and associated payments to reflect the new transfer mode
    if self.payment_mode.present? # i.e. there is a change in the mode of payment
      unless self.payment_order.update(payment_mode: self.payment_mode) && self.payment_order.payments.update_all(payment_mode: self.payment_mode)
        add_message :error, payment_order.errors.full_messages
        return
      end
    end
    # calling payment executor so that the payment can be successfully executed using the respective adapters
    op = AccountManager::Payments::PaymentExecutor.(self.payment, bank_transfer_type: payment.reload.payment_mode)
    if op.success?
      if self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:completed)] || self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:processing)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
      elsif self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:failed)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      else
        # this is partially completed
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      end
      # update the retry count for this particular payment
      self.payment.update(retry_count: (payment.retry_count + 1))
    else
      # no change in the payment order or payment anyway. So do nothing?
    end
  end

  def post_process
    # update processed amount for this payment order
    self.payment_order.update_processed_amount
    self.payment_order.update_order_status
    add_message :success, "Payment retry successfully executed"
  end
  
end