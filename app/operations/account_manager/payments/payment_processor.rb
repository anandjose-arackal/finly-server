# this operation will take the payment request object from the respective operation in EM / Disburse / Vendor Payment
# and create the respective models required for execution of the payment
# this operation is only called for payment specific operations in the system - other card and wallet related
# operations are performed through other operations inside account manager

class AccountManager::Payments::PaymentProcessor < BaseOperation

  attr_accessor :payment_order_params, :payment_order, :payment_request, :company

  def init
    # create the payment order object and associated payments
    self.payment_request = params[:payment_request]
    self.payment_order_params = retrieve_payment_order_params
    self.company = user.company

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

    # if payment order has been scheduled for execution right away, process it right now
    if payment_order.payment_order_status_id == PaymentOrderStatus.id_for(:pending)
      # if the order is synchronous, perform it using the regular call method in payment executor
      if payment_request.synchronous
        # now iterating through each payment order and performing the respective transfer
        payment_order.payments.each do |payment|
          AccountManager::Payments::PaymentExecutor.(payment)
        end
      else
        # call the payment executor that runs the payments in the background
        # passing the payment id here because async operation can retrieve the object
        payment_order.payments.each do |payment|
          AccountManager::Payments::PaymentExecutor.call_async(payment.id)
        end
      end
    end
  end

  def success
    params[:payment_oder] = payment_order
    AccountManager::Payments::PaymentProcessor::PaymentsPresenter.new(user, params, messages)
  end

  def failure
    params[:payment_order] = payment_order
    AccountManager::Payments::PaymentProcessor::PaymentsPresenter.new(user, params, messages)
  end

  class AccountManager::Payments::PaymentProcessor::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payments, :payment_order

    def init
      
      self.payment_order = params[:payment_order]
      self.payments = payment_order.payments
    end
  end

  private

  def retrieve_payment_order_params
    p = {}
    p[:payment_order_type_id] = payment_request.payment_order_type_id
    p[:payment_order_status_id] = payment_request.retrieve_payment_order_status
    p[:initiating_user_id] = payment_request.initiating_user_id
    p[:company_id] = user.company_id # assuming there will be a user executing this particular operation
    p[:scheduled_at] = payment_request.scheduled_at
    p[:payments_attributes] = []
    payment_request.payment_items.each do |pi|
      p[:payments_attributes] << {
          payment_type_id: pi[:payment_type_id],
          receiving_user_id: pi[:receiving_user_id],
          initiating_user_id: pi[:initiating_user_id],
          initiating_account_id: pi[:initiating_account_id],
          initiating_account_type: pi[:initiating_account_type],
          receiving_account_type: pi[:receiving_account_type],
          receiving_account_id: pi[:receiving_account_id],
          payment_status_id: PaymentStatus.id_for(:pending),
          amount_attributes: pi[:amount_attributes],
          date: pi[:date]
      }
    end
    p
  end

end
