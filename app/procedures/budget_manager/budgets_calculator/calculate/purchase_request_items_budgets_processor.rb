class BudgetManager::BudgetsCalculator::Calculate::PurchaseRequestItemsBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(purchase_request_item)
    trail = BudgetTrail.find_by(entity_type: "PurchaseRequestItem", entity_id: purchase_request_item.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end

    self.trail_hash = {
        id: trail_id,
        entity: purchase_request_item,
        category_id: purchase_request_item.category_id,
        cost_center_id: purchase_request_item.cost_center_id,
        user_id: purchase_request_item.purchase_request.creator_id,
        location_id: purchase_request_item.purchase_request.location_id,
        department_id: purchase_request_item.purchase_request.department_id,
        date: purchase_request_item.purchase_request.created_at,
        entity_created_at: purchase_request_item.purchase_request.created_at,
        entity_submitted_at: (purchase_request_item.purchase_request.submitted_at || purchase_request_item.purchase_request.created_at),
        entity_status_id: purchase_request_item.purchase_request.purchase_request_status_id,
        amount_attributes: {
            id: trail&.amount&.id,
            value: purchase_request_item.estimated_amount&.value,
            currency_id: purchase_request_item.estimated_amount&.currency_id
        },
        amount_before_tax_attributes: {
            id: trail&.amount_before_tax&.id,
            value: purchase_request_item.estimated_amount&.value,
            currency_id: purchase_request_item.estimated_amount&.currency_id
        },
        amount_after_tax_attributes: {
            id: trail&.amount_after_tax&.id,
            value: purchase_request_item.estimated_amount&.value,
            currency_id: purchase_request_item.estimated_amount&.currency_id
        }
    }
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(purchase_request_item)
    budget_trail = BudgetTrail.find_by(entity_type: "PurchaseRequestItem", entity_id: purchase_request_item.id)
    budget_trail&.destroy
  end

end