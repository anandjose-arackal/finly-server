class BudgetManager::BudgetsCalculator::Calculate::PurchaseOrderBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  def self.save_trail(purchase_order)
    self.trail_hash = {
        entity: purchase_order,
        location_id: purchase_order&.location_id,
        department_id: purchase_order.department_id,
        user_id: purchase_order.user_id,
        amount_attributes: {
            value: purchase_order&.total_after_tax&.value,
            currency_id: purchase_order.total_after_tax.currency_id
        }
    }
    super()
  end
end