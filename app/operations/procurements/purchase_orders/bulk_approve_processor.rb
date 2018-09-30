class Procurements::PurchaseOrders::BulkApproveProcessor < BackgroundOperation
  attr_accessor :purchase_order_ids

  def init
    self.purchase_order_ids = params[:purchase_order_ids]
  end

  def validate
    if self.purchase_order_ids.blank?
      return
    end
  end

  def process
    purchase_order_ids.each do |id|
      Procurements::PurchaseOrders::Approve.(user, {purchase_order_id: id})
    end
  end
end