class Procurements::PurchaseOrders::AdvancePayments < Procurements::PurchaseOrders::Base

  attr_accessor :purchase_order, :advance_payments

  class Procurements::PurchaseOrders::AdvancePayments::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :advance_payments

    def init
      self.advance_payments = params[:advance_payments]
    end

  end

  def init
    id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by(id: id)
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase order not found"
    end
  end

  def process
    self.advance_payments = self.purchase_order.advance_payments
  end

  def success
    params[:advance_payments] = self.advance_payments
    Procurements::PurchaseOrders::AdvancePayments::PaymentsPresenter.new(user, params, messages)
  end
end