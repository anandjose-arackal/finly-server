class BudgetManager::BudgetsCalculator::Calculate::MoneyRequestItemBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :trail_hash

  def save_trail(money_request_item)
    trail = BudgetTrail.find_by(entity_type: "MoneyRequestItem", entity_id: money_request_item.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end
    self.trail_hash = {
        id: trail_id,
        entity: money_request_item,
        category_id: money_request_item.money_request_item_category&.category_id,
        user_id: money_request_item.money_request.user_id,
        cost_center_id: money_request_item.money_request.cost_center_id,
        department_id: money_request_item.money_request.department_id,
        location_id: money_request_item.money_request.location_id,
        date: money_request_item.created_at.to_date,
        entity_created_at: money_request_item.created_at,
        entity_submitted_at: money_request_item.money_request.submitted_at,
        entity_status_id: money_request_item.money_request.status_id,
        amount_attributes: {
            id: trail&.amount&.id,
            value: money_request_item.amount_value,
            currency_id: money_request_item.amount&.currency_id
        },
        amount_before_tax_attributes: {
            id: trail&.amount_before_tax&.id,
            value: money_request_item.amount_value,
            currency_id: money_request_item.amount&.currency_id
        },
        amount_after_tax_attributes: {
            id: trail&.amount_after_tax&.id,
            value: money_request_item.amount_value,
            currency_id: money_request_item.amount&.currency_id
        }
    }
    # now calling super so that the budget trail is saved
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(money_request_item)
    budget_trail = BudgetTrail.find_by(entity_type: "MoneyRequestItem", entity_id: money_request_item.id)
    budget_trail&.destroy
  end
end
