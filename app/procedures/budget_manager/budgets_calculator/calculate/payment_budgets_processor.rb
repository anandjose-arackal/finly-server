class BudgetManager::BudgetsCalculator::Calculate::PaymentBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(payment)
    trail = BudgetTrail.find_by(entity_type: "Payment", entity_id: payment.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end
    self.trail_hash = {
        id: trail_id,
        entity: payment,
        category_id: payment.category_id,
        cost_center_id: payment.cost_center_id,
        vendor_id: (payment.receiving_account_id if payment.receiving_account_type == "YesBankVendor"),
        department_id: payment.department_id,
        location_id: payment.location_id,
        user_id: payment.initiating_user_id,
        date: payment.date,
        entity_status_id: payment.payment_status_id,
        entity_created_at: payment.bank_payment_request.created_at,
        entity_submitted_at: payment.bank_payment_request.submitted_at,
        amount_attributes: {
            id: trail&.amount&.id,
            value: payment.amount.value,
            currency_id: payment.amount.currency_id
        },
        amount_before_tax_attributes: {
            id: trail&.amount_before_tax&.id,
            value: payment.amount_value,
            currency_id: payment.amount.currency_id
        },
        amount_after_tax_attributes: {
            id: trail&.amount_after_tax&.id,
            value: payment.amount_value,
            currency_id: payment.amount.currency_id
        }
    }
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(payment)
    budget_trail = BudgetTrail.find_by(entity_type: "Payment", entity_id: payment.id)
    budget_trail&.destroy
  end
end