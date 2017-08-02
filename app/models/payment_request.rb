# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.
# background - whether the request is to be executed real time, or if it should be scheduled in the BG
# payment items will most likely be a hash of details that are relevant to that particular payment object

class PaymentRequest
  include Initializable

  attr_accessor :company_id, :scheduled_at, :background,
                :payment_items, :initiating_user_id, :payment_order_type_id,
                :initiating_account_id, :initiating_account_type,
                :receiving_account_id, :receiving_account_type,
                :order_currency

  def retrieve_payment_order_status
    if self.scheduled_at.present? && self.scheduled_at > DateUtils.local_date
      return PaymentOrderStatus.id_for(:scheduled)
    else
      return PaymentOrderStatus.id_for(:pending)
    end
  end

  def request_total
    total = 0
    self.payment_items.each do |pi|
      total += pi[:amount_attributes]&.dig(:value)&.to_f
    end
    total
  end

  def request_currency_id
    # for now will just be INR, can change in the future
    Currency.id_for(:INR)
  end

end