class BudgetsCalculator::Calculate::PurchaseOrderItemsBudgetsProcessor < BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(purchase_order_item)
    trail = BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: purchase_order_item.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end
    self.trail_hash = {
        id: trail_id,
        entity: purchase_order_item,
        category_id: (purchase_order_item.category_id || purchase_order_item.inventory_line_item.category_id),
        # cost_center_id: purchase_order_item.cost_center_id,
        user_id: purchase_order_item.purchase_order.user_id,
        location_id: purchase_order_item.purchase_order.location_id,
        # department_id: purchase_order_item.department_id,
        date: purchase_order_item.purchase_order.created_at,
        procurement_id: purchase_order_item.purchase_order.procurement_id,
        amount_attributes: {
            value: purchase_order_item.total_amount&.value,
            currency_id: purchase_order_item.total_amount&.currency_id
        }
    }
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(purchase_order_item)
    budget_trail = BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: purchase_order_item.id)
    budget_trail&.destroy
  end

end