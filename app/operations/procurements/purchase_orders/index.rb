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

      # Get all the policies
      policy_ids = user.company.policies.with_application(:vp).pluck(:id)

      # Get all level ids of type purchase order and with policy ids from above
      policy_level_ids = ReviewalLevel.with_entity_type('PurchaseOrderProvider').with_policy_ids(policy_ids).pluck(:id)

      # Get all level ids from level reviewer mapping with current user id
      reviewer_level_ids = LevelReviewerMapping.with_reviewer_id(user.id).pluck(:level_id)

      # Get common levels
      level_ids = policy_level_ids & reviewer_level_ids

      # Find all the purchase order with controlling level from above
      purchase_order_ids = user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:id)
      # Find all document level reviewer mapping with with the above list of level + reviewer and get their po id
      purchase_order_ids += ::DocumentLevelReviewerMapping.with_level_ids(level_ids).with_reviewer_ids(user.id).with_document_type('PurchaseOrder').pluck(:document_reviewer_mappable_id)
      # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
      other_reviewer_po_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('PurchaseOrder').pluck(:document_reviewer_mappable_id)

      purchase_order_ids -= other_reviewer_po_ids

      self.purchase_orders = user.company.purchase_orders.with_id(purchase_order_ids).with_status_ids(PurchaseOrderStatus.id_for(:processing))

      all_level_ids = self.purchase_orders.pluck(:controlling_level_id)

      self.purchase_orders = self.purchase_orders.with_controlling_level_ids(level_ids & all_level_ids)
    end
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