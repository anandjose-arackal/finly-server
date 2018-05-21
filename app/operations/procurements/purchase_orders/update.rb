class Procurements::PurchaseOrders::Update < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    self.purchase_order_params = purchase_order_parameters
    # self.procurement = user.company.procurements.find_by params[:procurement_id]
    self.purchase_order = PurchaseOrder.find_by params[:id] || params[:purchase_order_id]
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    # self.purchase_order = procurement.build_purchse_order(purchase_order_params)
    purchase_order.assign_attributes(purchase_order_params)

    if purchase_order.valid?
      purchase_order.save
      add_message :success, 'Successfully updated purchase order'
    end
  end
end