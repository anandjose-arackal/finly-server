class Procurements::PurchaseOrders::Template::Index < Procurements::PurchaseOrders::Template::Base
  attr_accessor :purchase_orders

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.purchase_orders = user.purchase_orders.templates
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Procurements::PurchaseOrders::Template::Index::SuccessPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Template::Index::SuccessPresenter < BaseOperation::BasePresenter
    attr_accessor :purchase_orders

    def init
      self.purchase_orders = params[:purchase_orders]
    end

  end

end