class Procurements::PurchaseOrders::Index < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :policies
  def init

  end

  def validate

  end

  def process
    # Only used for getting pending approval
    if user.vendor_payments_reviewer?
      level_ids = []
      policies = user.company.policies.with_application(:vp)
      policies.each do |policy|
        levels = policy.levels.with_entity_type('PurchaseOrder')
        levels.each do |level|
          if level.reviewers.pluck(:id).include? user.id
            level_ids.push(level.id)
          end
        end
      end
    end

    # Find all the purchase order with controlling level from above
    purchase_order_ids = user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:id)

    # Find all document level reviewer mapping with with the above list of level + reviewer and get their po id
    purchase_order_ids += ::DocumentLevelReviewerMapping.with_level_ids(level_ids).with_reviewer_ids(user.id).with_document_type('PurchaseOrder').
                                                                                   pluck(:document_reviewer_mappable_id)

    # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
    other_reviewer_po_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('PurchaseOrder').pluck(:document_reviewer_mappable_id)

    purchase_order_ids -= other_reviewer_po_ids

    self.purchase_orders = user.company.purchase_orders.with_id(purchase_order_ids).with_status_ids(PurchaseOrderStatus.id_for(:processing))

  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Procurements::PurchaseOrders::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders

    def init
      self.purchase_orders = params[:purchase_orders]
    end

  end
end