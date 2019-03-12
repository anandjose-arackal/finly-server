class Procurements::PurchaseOrders::Index < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :policies
  def init

  end

  def validate

  end

  def process
    # Only used for getting pending approval
    if user.vendor_payments_reviewer?

      self.purchase_orders = PurchaseOrder.awaiting_action_items(user)
    end
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Procurements::PurchaseOrders::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders

    def init
      self.purchase_orders = params[:purchase_orders]
    end

  end
end