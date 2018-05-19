class Procurements::PurchaseOrders::Create < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :procurement, :purchase_order_params

  def init
    self.purchase_order_params = purchase_order_parameters
    self.procurement = user.company.procurements.find_by params[:procurement_id]
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end
  end

  def process
    self.purchase_order = procurement.build_purchse_order(purchase_order_params)
    if purchase_order.valid?
      purchase_order.save
      add_message :success, 'Successfully created purchase order'
    end
  end
end