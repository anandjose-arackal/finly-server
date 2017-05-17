class Orders::OrderCards::Index < Orders::OrderCards::Base
  attr_accessor :payment_orders, :params_order_cards

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    # if params.blank?
    #   add_message :error, 'Error loading configuration'
    #   return
    # end
  end

  def init
    self.params_order_cards = order_cards_params

    # Show all payment_order_types if no id is given
    if self.params_order_cards[:order_type_ids].empty?
      self.params_order_cards[:order_type_ids].push(1, 2, 3, 4)
    end
  end

  def process
    self.payment_orders = user.company.payment_orders.with_type_id(params_order_cards[:order_type_ids])
  end

  def success
    params[:payment_orders] = self.payment_orders
    Orders::OrderCards::Index::SuccessPresenter.new(user, params, messages)
  end

  class Orders::OrderCards::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_orders

    def init
      self.payment_orders = params[:payment_orders]
    end
  end
end