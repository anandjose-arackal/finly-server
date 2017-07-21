# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.
# synchronous - whether the request is to be executed real time, or if it should be scheduled in the BG
# payment items will most likely be a hash of details that are relevant to that particular payment object

class PaymentRequest

  attr_accessor :initiating_account_id, :receiving_account_id, :type, :scheduled_on, :synchronous,
                :payment_items, :synchronous, :initiating_user_id

  def retrieve_payment_order_status
    if self.scheduled_on != DateUtils.local_date
      return PaymentOrderStatus.id_for(:scheduled)
    else
      return PaymentOrderStatus.id_for(:pending)
    end
  end

  def retrieve_payment_order_type_id
    PaymentOrderType.id_for(self.type)
  end

end