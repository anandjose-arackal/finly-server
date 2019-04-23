# This operation deletes an existing quotation for a purchase order

class Procurements::PurchaseOrders::Quotations::Destroy < Procurements::PurchaseOrders::Quotations::Base
  attr_accessor :purchase_order, :quotation

  def pre_validate
      if params[:purchase_order_id].blank?
        add_message :error, "Purchase Order not found"
        return
      end

      if params[:id].blank?
        add_message :error, "Quotation ID not sent."
        return
      end

  end

  def init
    purchase_order_id = params[:purchase_order_id]
    quotation_id = params[:id] || params[:quotation_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.quotation = self.purchase_order.quotations.find_by id: quotation_id
  end

  def validate
    if self.purchase_order.blank?
      add_message :error, "Purchase Order not found."
      return
    end

    if self.quotation.blank?
      add_message :error, "No quotations found."
      return
    end 

    unless self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?
      add_message :error, "Quotations cannot be deleted if Purchase Order is submitted."
      return
    end

  end

  def process
    if self.quotation.destroy
      add_message :success, "Successfully deleted Quotation"
    end
  end
end
