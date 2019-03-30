# this operation will take the payment request object from the respective operation in EM / Disburse / Vendor Payment
# and create the respective models required for execution of the payment
# this operation is only called for payment specific operations in the system - other card and wallet related
# operations are performed through other operations inside account manager

# TODO - slightly changing the payment processor to handle all payments as crediting payments even if the entire
# order is being processed together
class AccountManager::Payments::PaymentProcessor < AccountManager::Base

  attr_accessor :payment_order_params, :payment_order, :payment_request, :company, :company_id, :options,
                :background, :crediting_payments

  def pre_validate
    if params&.dig(:payment_request).blank? && params&.dig(:payment_order).blank? && params&.dig(:crediting_payments).blank?
      add_message :error, 'Payment Request not found'
      return
    end
    if params&.dig(:payment_request).present?
      unless params[:payment_request].valid?
        add_message :error, params[:payment_request].errors.full_messages
      end
    end

    if params&.dig(:crediting_payments).present?
      if params&.dig(:crediting_payments).empty?
        add_message :error, "Crediting payments cannot be empty"
      end
    end
  end

  def init
    # create the payment order object and associated payments, if the payment request is present
    self.payment_request = params[:payment_request]
    if payment_request.present?
      self.company = Company.find_by(id: company_id)
      self.options = {}
      self.options[:bank_transfer_type] = params[:bank_transfer_type]
      self.background = params[:background] || self.payment_request.background
    end

    # setting the company id based on whether it's a user or an AdminUser
    if user.is_a?(User)
      self.company_id = user.company_id
      self.company = user.company
    elsif user.is_a?(AdminUser)
      self.company_id = payment_request.company_id
      self.company = Company.find_by(id: self.company_id)
    end

    # if it's not a payment request and is a PaymentOrder or a bunch of payments that are to be credited,
    # set crediting_payments as that list of payments
    if payment_order.blank? and payment_request.present?
      self.payment_order = payment_request.build_payment_order
      unless self.payment_order.save
        add_message :error, self.payment_order.errors.full_messages
      end
      self.crediting_payments = self.payment_order.payments
      self.options = {}
      self.options[:bank_transfer_type] = payment_order.bank_transfer_type
      self.background = true
    end

    # if none of the above, i.e. payment request or payment order both are not present,
    # the only remaining thing to check is crediting payments
    self.crediting_payments = params[:crediting_payments]
  end

  def validate
    # by this time the payment order will exist for sure
    # Call the payment validator class that validates the payment order
    result = PaymentProcessorRules::Event.(:payment_passes_standard_violations, {payment_order: self.payment_order, crediting_payments: self.crediting_payments})
    unless result.success?
      add_message :error, result.messages
    end

    op = AccountManager::Payments::PaymentValidator.(payment_order, self.crediting_payments, {payment_process: true})
    unless op.success?
      add_message :error, op.messages[:error]
    end
  end

  def pre_process
    # persisting the payment order to database before processing with anything else
    unless payment_order.save
      add_message :error, payment_order.errors.full_messages
      return
    end

    PaymentProcessorRules::Event.(:payment_order_status_is_pending, {payment: self.payment})
    # also set the payment order's status id as either scheduled or as pending
    if self.crediting_payments.present? && self.crediting_payments.pluck(:scheduled_at).uniq&.compact.blank?
      self.payment_order&.with_lock do
        self.payment_order.reload # kinda redundant since with_lock already reloads the data
        if self.payment_order.pending? || self.payment_order.in_progress?
          add_message :error, "This payment order is already being processed"
          return
        else
          payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
          self.crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
        end
      end
    else
      if payment_order.scheduled_at.present? && payment_order.scheduled_at > DateUtils.local_date
        payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:scheduled))
        if self.crediting_payments.present?
          self.crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:scheduled))
        else
          self.payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:scheduled))
        end
      else
        self.payment_order.with_lock do
          self.payment_order.reload # kinda redundant since with_lock already reloads the data
          if self.payment_order.pending? || self.payment_order.in_progress?
            add_message :error, "This payment order is already being processed"
            return
          else
            payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
            self.payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
          end
        end
      end
    end
  end

  def process
    # now the actual execution of the payment order, based on whether it's
    # synchronous or a background operation
    if self.crediting_payments.present?
      if self.background && self.crediting_payments.pluck(:scheduled_at).uniq&.compact.blank?
        options[:crediting_payment_ids] = self.crediting_payments.pluck(:id)
        # op = AccountManager::Payments::BulkPaymentExecutor.(self.payment_order, options)
        op = AccountManager::Payments::BulkPaymentExecutor.call_async(self.payment_order, options)
        add_message :success, 'Payments have initiated, you can check their status from the order screen'
      end
    else
      # if payment order has been scheduled for execution right away, process it right now
      if payment_order.payment_order_status_id == PaymentOrderStatus.id_for(:pending)
        # if the order is not background, perform it using the regular call method in payment executor
        if self.background
          #   # call the payment executor that runs the payments in the background
          #   # passing the payment id here because async operation can retrieve the object
          result = AccountManager::Payments::PaymentOrderExecutor.call_async(payment_order.id, options)
          add_message :success, 'Payments have been scheduled, you can check their status from the order screen'
        else
          # Process the order synchronously
          result = AccountManager::Payments::PaymentOrderExecutor.(payment_order, options)
          if result.success?
            add_message :success, 'Payment processed successfully'
          else
            # overriding this for testing
            # payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
            # payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:completed))
            add_message :error, result.messages[:error]
          end
        end
      end
    end
  end

  def post_process

  end


  def success
    params[:payment_order] = payment_order
    AccountManager::Payments::PaymentProcessor::PaymentsPresenter.new(user, params, messages)
  end

  def failure
    params[:payment_order] = payment_order
    AccountManager::Payments::PaymentProcessor::PaymentsFailurePresenter.new(user, params, messages)
  end

  class AccountManager::Payments::PaymentProcessor::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments, :payment_order

    def init
      self.payment_order = params[:payment_order]
      self.payments = payment_order&.payments
    end
  end

  class AccountManager::Payments::PaymentProcessor::PaymentsFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :payments, :payment_order

    def init
      self.payment_order = params[:payment_order]
      self.payments = payment_order&.payments
    end
  end

end