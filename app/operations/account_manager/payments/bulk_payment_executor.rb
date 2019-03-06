class AccountManager::Payments::BulkPaymentExecutor < AccountManager::Base

  attr_accessor :crediting_payments, :options, :retry_attempt, :payment_order

  def self.call(payment_order, options = {})
    payment_order_id = payment_order
    if payment_order_id.present? and payment_order_id.is_a?(PaymentOrder)
      payment_order_id = payment_order_id.id
    end
    self.new.perform(payment_order_id, options)
  end

  def perform(payment_order_id, options, request_store_hash=nil)
    load_request_store request_store_hash
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_order = PaymentOrder.unscoped.find_by_id(payment_order_id)
    self.crediting_payments = self.payment_order.payments.with_id(options[:crediting_payment_ids])
    self.options = options
    self.run
  end

  def self.perform_async(payment_order_id, options)
    # in case the object is passed directly instead of an id
    payment_order_id = payment_order_id
    if payment_order_id.present? && payment_order_id.is_a?(PaymentOrder)
      payment_order_id = payment_order_id.id
    end
    # calls the Sidekiq::Worker method
    super(payment_order_id, options)
  end

  def initialize
    # self.payment_order = payment_order
    # self.options = options
  end

  def pre_validate
    if self.crediting_payments.empty?
      add_message :error, 'No payments to process'
      return
    end

    # ideally all payments that are reaching this state should be processable
    # the check for that happens before the payment reaches this state

  end

  def validate
    unless self.payment_order.pending?
      add_message :error, "Payment order cannot be processed at this moment"
      return
    end
  end

  def pre_process
    # in progress because technically even though only some payments are being processed in this order,
    # the order is still in progress
    payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:in_progress))
  end

  def init
    self.retry_attempt = options[:retry]
  end

  def process
    # now iterating through each payments in the order and performing the respective transfer
    succeeded_transactions = false
    failed_transactions = false
    processing_transactions = false
    processed_amount = 0
    error_messages = []

    # now scope the payments to just the failed ones if it's a retry, otherwise, execute normally
    if self.retry_attempt
      self.crediting_payments = self.crediting_payments.failed
    end


    self.crediting_payments.each do |payment|
      op = AccountManager::Payments::PaymentExecutor.(payment, options)
      if op.success? && ([PaymentStatus.id_for(:completed)].include?(payment.payment_status_id))
        processed_amount += payment.amount_value
        succeeded_transactions = true
      elsif [PaymentStatus.id_for(:processing), PaymentStatus.id_for(:possible_failure)].include?(payment.payment_status_id)
        processed_amount += payment.amount_value
        processing_transactions = true
      else
        failed_transactions = true
        error_messages += op.messages[:error] if op.messages[:error].present?
      end
    end
    payment_order.update(amount_processed_attributes: {value: processed_amount,
                                                       currency_id: payment_order.currency_id},
                         processed_at: DateUtils.local_date_time)

    # Check if all transactions have passed successfully, or if it is a partial success or if its a complete failure
    if failed_transactions and not (succeeded_transactions || processing_transactions)
      # Failed
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      if error_messages.present?
        add_message :error, error_messages.uniq
      else
        add_message :error, 'Fund transfer failed. Please try again'
      end
    elsif not failed_transactions and succeeded_transactions
      # Completed
      if processing_transactions
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      else
        # here check if all the payments have been processed, if they are, mark as completed, otherwise mark as partially credited
        if self.crediting_payments.completed.count == self.payment_order.payments.count
          payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
        else
          payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
        end
      end
      add_message :success, 'Funds transferred successfully'
    else
      # Partially Completed
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      add_message :error, 'Some payments have failed'
      add_message :error, error_messages
    end
  end

  def post_process

  end

  def execute_post_operations(success)
    self.payment_order.execute_post_operation(success)
  end

end