# this will retry a single payment order asynchronously when requested -
# will have to pass {retry: true} for it to execute correctly

class AccountManager::Payments::CancelPaymentOrder < AccountManager::Base
  attr_accessor :payment_order

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    self.payment_order = params[:payment_order]
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
      return
    end
    unless self.payment_order.scheduled?
      add_message :error, 'Order cannot be cancelled at this stage'
    end
  end

  def process
    if self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:cancelled))
      self.payment_order.payments.each do |payment|
        unless payment.in_progress?
          payment.update(payment_status_id: PaymentStatus.id_for(:cancelled))
        end
      end
    else
      add_message :error, self.payment_order.errors.full_messages
    end
  end

end