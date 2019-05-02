class Procurements::PurchaseOrders::BulkApprove < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders

  def pre_validate
    super
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    purchase_order_ids = params[:ids] || params[:purchase_order_ids]

    unless purchase_order_ids.is_a?(Array)
      add_message :error, 'Invalid configuration'
      return
    end

    self.purchase_orders = user.company.purchase_orders.with_id(purchase_order_ids)
  end

  def validate
    if self.purchase_orders.empty?
      add_message :error, 'No Purchase Orders found'
    end
    accept_po = []
    self.purchase_orders.each do |purchase_order|
      valid = (purchase_order.can_really_approve?) ? true : false

      if valid
        accept_po << purchase_order.id
      end
    end
 
    self.purchase_orders = self.purchase_orders.where(id: accept_po)

    if self.purchase_orders.blank?
      add_message :error, "None of the purchase orders are in a state to be approved"
      return
    end

  end

  def process
    Procurements::PurchaseOrders::BulkApproveProcessor.call_async(user.id, {purchase_order_ids: purchase_orders.pluck(:id)})
    # Procurements::PurchaseOrders::BulkApproveProcessor.call(user.id, {purchase_order_ids: purchase_orders.pluck(:id)})
  end

  def post_process
    add_message :success, "Purchase Orders are being approved. You will be notified via mail once all are approved"
  end
end