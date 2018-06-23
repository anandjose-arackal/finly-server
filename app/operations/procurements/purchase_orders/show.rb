class Procurements::PurchaseOrders::Show < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order
  def init
    purchase_order_id = params[:id] || params[:purchase_order_params]
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not Found'
    end
  end

  def process
    if self.purchase_order.po_number.blank?
      op = Procurements::DocumentNumbers::Generate.(user, {document: self.purchase_order})
      if op.success?
        self.po_number = op.document_number
      end
    end
  end

  def success
    params[:purchase_order] = self.purchase_order
    Procurements::PurchaseOrders::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order

    def init
      self.purchase_order = params[:purchase_order]
    end
  end

end