class Procurements::PurchaseOrders::Destroy < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
    self.procurement = self.purchase_order.procurement
  end

  def validate
    unless PurchaseOrderStatus.ids_for([:open, :retracted, :rejected]).include? purchase_order.status.id
      add_message :error, "You can't delete purchase order at this state."
    end
  end

  def process
    if self.procurement.po_revisions.present?
      if self.purchase_order.destroy
        add_message :success, "Successfully Deleted Purchase Order."
        return
      end
    else       
      if self.procurement.destroy
        add_message :success, "Successfully Deleted Procurement"
      end
    end
  end
end