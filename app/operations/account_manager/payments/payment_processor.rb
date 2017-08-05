# this operation will take the payment request object from the respective operation in EM / Disburse / Vendor Payment
# and create the respective models required for execution of the payment
# this operation is only called for payment specific operations in the system - other card and wallet related
# operations are performed through other operations inside account manager

class AccountManager::Payments::PaymentProcessor < AccountManager::Base

  attr_accessor :payment_order_params, :payment_order, :payment_request, :company, :company_id, :options

  def pre_validate
    if params&.dig(:payment_request).blank?
      add_message :error, 'Payment Request not found'
      return
    end
    unless params[:payment_request].valid?
      add_message :error, params[:payment_request].errors.full_messages
    end
  end

  def init
    # create the payment order object and associated payments
    self.payment_request = params[:payment_request]
    self.payment_order_params = retrieve_payment_order_params
    if user.is_a?(User)
      self.company_id = user.company_id
    else
      self.company_id = params[:company_id]
    end
    self.company = Company.find_by(id: company_id)
    self.options = {}
    self.options[:bank_transfer_type] = params[:bank_transfer_type]
    # creating the payment order first to check for violations and shit
    self.payment_order = company.payment_orders.build(payment_order_params)

    unless payment_order.valid?
      add_message :error, payment_order.errors.full_messages
      return
    end
  end

  def validate
    # Call the payment validator class that validates the payment order
    op = AccountManager::Payments::PaymentValidator.(payment_order)
    
    unless op.success?
      add_message :error, op.messages[:error]
    end
  end

  def process
    # now the actual execution of the payment order, based on whether it's
    # synchronous or a background operation
    unless payment_order.save
      add_message :error, payment_order.errors.full_messages
    end
    # if payment order has been scheduled for execution right away, process it right now
    if payment_order.payment_order_status_id == PaymentOrderStatus.id_for(:pending)
      # if the order is not background, perform it using the regular call method in payment executor
      if payment_request.background
        # call the payment executor that runs the payments in the background
        # passing the payment id here because async operation can retrieve the object
        result = AccountManager::Payments::PaymentOrderExecutor.call_async(payment_order.id, options)
        # if result.success?
        #   add_message :success, 'Processing payments'
        # else
        #   add_message :error, result.messages[:error]
        # end
        add_message :success, "Payments have been scheduled, you can check their status from the order screen"
      else
        # Process the order synchronously
        result = AccountManager::Payments::PaymentOrderExecutor.(payment_order, options)
        if result.success?
          add_message :success, 'Payment processed successfully'
        else
          add_message :error, result.messages[:error]
        end
      end
    end
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

  private

  def retrieve_payment_order_params
    p = {}
    p[:payment_purpose_id] = payment_request.payment_purpose_id
    p[:payment_order_status_id] = payment_request.retrieve_payment_order_status
    p[:initiating_user_id] = payment_request.initiating_resource_id
    p[:company_id] = user.company_id # assuming there will be a user executing this particular operation
    p[:scheduled_at] = payment_request.scheduled_at
    p[:initiating_account_type] = payment_request.initiating_account_type
    p[:receiving_account_type] = payment_request.receiving_account_type
    p[:currency_id] = payment_request.currency_id
    p[:amount_requested_attributes] = {
        value: payment_request.request_total,
        currency_id: payment_request.currency_id
    }
    p[:payments_attributes] = []
    payment_request.payment_items.each do |pi|
      p[:payments_attributes] << {
          payment_type_id: pi.payment_type_id,
          receiving_user_id: pi.receiving_resource_id,
          receiving_user_type: pi.receiving_resource_type,
          initiating_user_id: pi.initiating_resource_id,
          initiating_user_type: pi.initiating_resource_type,
          initiating_account_id: pi.initiating_account_id,
          initiating_account_type: pi.initiating_account_type,
          receiving_account_type: pi.receiving_account_type,
          receiving_account_id: pi.receiving_account_id,
          payment_status_id: pi.payment_status_id,
          payment_purpose_id: pi.payment_purpose_id,
          amount_attributes: {
              value: pi.amount,
              currency_id: pi.currency_id
          },
          date: pi.date
      }
    end
    p
  end

end

