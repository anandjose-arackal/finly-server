class Procurements::PurchaseOrders::PoAdvances < Procurements::PurchaseOrders::Base

  attr_accessor :purchase_order, :advance_payments, :ids

  class Procurements::PurchaseOrders::PoAdvances::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :advance_payments

    def init
      self.advance_payments = params[:advance_payments]
    end

  end

  def init
    # id = params[:id] || params[:purchase_order_id]
    # self.purchase_order = user.company.purchase_orders.find_by(id: id)
    self.ids = user.company.procurements.pluck(:id).uniq
    # self.advance_payments = Payment.where(procurement_id: ids)
  end

  def validate
    # if self.purchase_order.blank?
    #   add_message :error, "Purchase order not found"
    # end
  end

  def process
    # self.advance_payments = self.purchase_order.advance_payments
    self.advance_payments = Payment.where(procurement_id: self.ids)
  end

  def success
    params[:advance_payments] = self.advance_payments
    Procurements::PurchaseOrders::PoAdvances::PaymentsPresenter.new(user, params, messages)
  end
end