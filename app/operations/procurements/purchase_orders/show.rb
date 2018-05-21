class Procurements::PurchaseOrders::Show < Procurements::PurchaseOrders::Base
  def init
    self.purchase_order = PurchaseOrder.find_by params[:id] || params[:purchase_order_params]
  end

  def validate

  end

  def success
    params[:purchase_order] = self.purchase_order
    Procurements::PurchaseOrders::Show::ShowPresenter.new(user, params, messages)

  end

  class Procurements::PurchaseOrders::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order

    def init
      self.purchase_order = params[:purchase_order]
    end
  end

end