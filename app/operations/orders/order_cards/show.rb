class Orders::OrderCards::Show < Orders::OrderCards::Base
  attr_accessor :payment_order, :actions

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
    self.actions = {}
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
    end
  end

  def process
    # debugger
    actions[:cancel] = true if self.payment_order.scheduled?
    # self.payment_orders = user.company.payment_orders.with_type_id(params_order_cards[:order_type_ids])
  end

  def success
    params[:payment_order] = self.payment_order
    params[:actions] = self.actions
    Orders::OrderCards::Show::SuccessPresenter.new(user, params, messages)
  end

  class Orders::OrderCards::Show::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order, :actions

    def init
      self.payment_order = params[:payment_order]
      self.actions = params[:actions]
    end
  end
end