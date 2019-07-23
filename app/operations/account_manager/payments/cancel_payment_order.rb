# this will retry a single payment order asynchronously when requested -
# will have to pass {retry: true} for it to execute correctly

class AccountManager::Payments::CancelPaymentOrder < AccountManager::Base
  attr_accessor :payment_order, :selected_payments, :remaining_payments

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

  def pre_process
    self.remaining_payments = false
    if params[:payment_ids].present?
      self.selected_payments = self.payment_order.payments.where id: params[:payment_ids]
      self.remaining_payments = (self.payment_order.payments - self.selected_payments).present? #see if anything is remaining, if so, dont change payment_order status
    else
      self.selected_payments = self.payment_order.payments
    end
  end

  def process
    if self.remaining_payments
      update_payments
    elsif self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:cancelled))
      update_payments
    else
      add_message :error, self.payment_order.errors.full_messages
    end
  end

  private

  def update_payments
    # new feature - in a batch, user can choose which items to cancel individually
    # this will make sure only those payments associated with the mr/report get cancelled if selected or all of them
    self.selected_payments.each do |payment|
      unless payment.in_progress?
        payment.update(payment_status_id: PaymentStatus.id_for(:cancelled))
      end
    end
  end

end
