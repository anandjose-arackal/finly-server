class BankTransfer::Payments::Count < BankTransfer::Payments::Base
  attr_accessor :payment_order_ids, :payments_count

  def init
    params[:with_application] = RequestStore.store[:current_app].to_s
    params[:filter_vendor_payments] = 1
  end

  def process
    op = BankTransfer::YesBank::Index.(current_user, params)
    if op.success?
      self.payment_order_ids = op.payment_orders.pluck(:id)
    else
      add_message :error, op.messages[:error]
    end
    self.payments_count = Payment.with_payment_order_id(payment_order_ids).count
  end

  def success
    payments_count
  end
end