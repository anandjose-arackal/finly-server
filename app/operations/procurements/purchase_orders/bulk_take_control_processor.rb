class Procurements::PurchaseOrders::BulkTakeControlProcessor < BackgroundOperation
  attr_accessor :purchase_order_ids, :result

  def init
    self.purchase_order_ids = params[:purchase_order_ids]
    self.result = {
        success: [],
        error: []
    }
  end

  def validate
    if self.purchase_order_ids.blank?
      return
    end
  end

  def process
    purchase_order_ids.each do |id|
      data_success = {}
      data_error = {}
      op = Procurements::PurchaseOrders::TakeControl.(user, {purchase_order_id: id})
      po = PurchaseOrder.find_by id: id
      unless op.success?
        data_error[:messages] = op.messages[:error]
        data_error[:po_number] = po&.po_number
        data_error[:sub_department] = po&.sub_department&.name
        data_error[:department] = po&.department&.name
        data_error[:user] = po&.user&.name
        data_error[:amount] = po&.balance_amount&.value
        self.result[:error].push(data_error)
      else
        data_success[:po_number] = po&.po_number
        data_success[:sub_department] = po&.sub_department&.name
        data_success[:department] = po&.department&.name
        data_success[:user] = po&.user&.name
        data_success[:amount] = po&.balance_amount&.value
        self.result[:success].push(data_success)
      end
    end
  end

  def post_process
    op = Event::EPurchaseOrder::BulkTakeControl.(user, result: result)
  end
end