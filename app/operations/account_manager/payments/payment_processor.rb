class AccountManager::Payments::PaymentProcessor < BaseOperation

  attr_accessor :payment_order_params, :payment_order, :payment_request

  def init
    # create the payment order object and associated payments
    self.payment_request = params[:payment_request]
    self.payment_order_params = retrieve_payment_order_params
  end

  def validate

  end

  def process

  end

  private

  def retrieve_payment_order_params
    p = {}
    p[:payment_order_type_id] = payment_request.retrieve_payment_order_type_id
    p[:payment_order_status_id] = PaymentOrderStatus.id_for(:pending)
    p[:initiating_user_id] = payment_request.initiating_user_id
  end

end
