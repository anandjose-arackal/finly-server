class Orders::OrderCards::Cancel < Orders::OrderCards::Base
  attr_accessor :payment_order

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:id].blank?
      add_message :error, 'Order not found'
      return
    end
  end

  def init
    self.payment_order = user.company.payment_orders.with_id(params[:id]).first rescue nil
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
        if payment.scheduled?
          payment.update(payment_status_id: PaymentStatus.id_for(:cancelled))
        end
      end
    else
      add_message :error, self.payment_order.errors.full_messages
    end
  end

  def success
    params[:payment_order] = self.payment_order
    Orders::OrderCards::Cancel::SuccessPresenter.new(user, params, messages)
  end

  class Orders::OrderCards::Cancel::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end
  end

end