class AccountManager::Payments::PaymentOrderExecutor < AccountManager::Base
  attr_accessor :payment_order, :options

  def self.call(payment_order, options = {})
    payment_order_id = payment_order
    if payment_order_id.present? and payment_order_id.is_a?(PaymentOrder)
      payment_order_id = payment_order_id.id
    end
    self.new.perform(payment_order_id, options)
  end

  def self.call_async(payment_order_id, options = {})
    # define the operation to accordingly run the operation in the background
    self.perform_async(payment_order_id, options)
  end

  def perform(payment_order_id, options)
    if options.present? and options.is_a?(Hash)
      options = options.with_indifferent_access
    end
    self.payment_order = PaymentOrder.find_by_id(payment_order_id)
    self.options = options
    self.run
  end

  def perform_async(payment_order_id, options)
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
    if self.payment_order.blank?
      add_message :error, 'Payment Order not found'
      return
    end
    if payment_order.completed?
      add_message :error, "This Payment order has already been processed"
      return
    end
  end

  def pre_process
    payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:in_progress))
  end

  def process
    # now iterating through each payment order and performing the respective transfer
    succeeded_transactions = false
    failed_transactions = false
    processed_amount = 0
    error_messages = []
    payment_order.payments.each do |payment|
      op = AccountManager::Payments::PaymentExecutor.(payment, options)
      if op.success? && (payment.reload.payment_status_id == PaymentStatus.id_for(:completed) || payment.payment_status_id == PaymentStatus.id_for(:processing))
        processed_amount += payment.amount_value
        succeeded_transactions = true
      else
        failed_transactions = true
        error_messages += op.messages[:error] if op.messages[:error].present?
      end
    end
    payment_order.update(amount_processed_attributes: {value: processed_amount,
                                                       currency_id: payment_order.currency_id},
                         processed_at: DateUtils.local_date_time)

    # Check if all transactions have passed successfully, or if it is a partial success or if its a complete failure
    if failed_transactions and not succeeded_transactions
      # Failed
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      if error_messages.present?
        add_message :error, error_messages.uniq
      else
        add_message :error, 'Fund transfer failed. Please try again'
      end
    elsif not failed_transactions and succeeded_transactions
      # Completed
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
      add_message :success, 'Funds transferred successfully'
    else
      # Partially Completed
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      add_message :error, 'Some payments have failed'
      add_message :error, error_messages
    end
  end

end