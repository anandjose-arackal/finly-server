# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.
# synchronous - whether the request is to be executed real time, or if it should be scheduled in the BG
# payment items will most likely be a hash of details that are relevant to that particular payment object

class PaymentRequest

  attr_accessor :company_id, :scheduled_at, :synchronous,
                :payment_items, :initiating_user_id, :payment_order_type_id,
                :initiating_account_id, :initiating_account_type,
                :receiving_account_id, :receiving_account_type

  def retrieve_payment_order_status
    if self.scheduled_at.present? && self.scheduled_at > DateUtils.local_date
      return PaymentOrderStatus.id_for(:scheduled)
    else
      return PaymentOrderStatus.id_for(:pending)
    end
  end

end