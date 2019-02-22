# Fetches purchase orders which have an advance amount attribute set to it.
# Not to be confused with advance payment, which we create later
# We return only those purchase orders for processing which have the advance amount status set as TO_BE_PROCESSED and FAILED
# cheers!

class Procurements::PurchaseOrders::PoWithAdvance < Procurements::PurchaseOrders::Base

  attr_accessor :purchase_orders

  class Procurements::PurchaseOrders::PoWithAdvance::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :purchase_order, :paginated_purchase_order

    def init
      self.purchase_order = params[:purchase_order]
      self.paginated_purchase_order = self.purchase_order.paginate(page: params[:page], per_page: (params[:per_page] || 30))
    end

  end

  def init
    self.purchase_orders = user.company.purchase_orders.where( purchase_order_status_id: [
                                                                                          PurchaseOrderStatus.id_for(:approved),
                                                                                          PurchaseOrderStatus.id_for(:auto_approved)
                                                                                        ], 
                                                              advance_amount_status_id: [
                                                                                          AdvanceAmountStatus.id_for(:to_be_processed),
                                                                                          AdvanceAmountStatus.id_for(:failed)
                                                                                        ])
  end

  def validate

    reject_po = []
    self.purchase_orders.each do |purchase_order|
      valid = true
      if purchase_order.advance_payments.present?
        valid = false
        if purchase_order.advance_amount_status_id == AdvanceAmountStatus.id_for(:failed)
          valid = true
        end
      end

      unless valid
        reject_po << purchase_order
      end
    end

    self.purchase_orders = self.purchase_orders.reject do |all_po|
        reject_po.any? do |po|
            all_po.id == po.id
        end
    end

    if self.purchase_orders.blank?
      add_message :error, "Purchase order with advance amount still to be processed or failed, were not found."
    end
  end

  def process
    params[:purchase_order] = self.purchase_orders
  end

  def success    
    Procurements::PurchaseOrders::PoWithAdvance::PaymentsPresenter.new(user, params, messages)
  end
end