# This operation deletes an existing quotation for a purchase order

class Procurements::PurchaseOrders::Quotations::Index < Procurements::PurchaseOrders::Quotations::Base
  attr_accessor :purchase_order, :quotations

  def pre_validate
      if params[:purchase_order_id].blank?
        add_message :error, "Purchase Order not sent."
        return
      end
  end

  def init
    purchase_order_id = params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.quotations = self.purchase_order.quotations
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase Order not found."
      return
    end

  end

  def process
  end

  def success
    params[:quotations] = self.quotations
    Procurements::PurchaseOrders::Quotations::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Quotations::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :quotations, :count

    def init
      self.quotations = params[:quotations]
      self.count = self.quotations.count
    end

  end

end
