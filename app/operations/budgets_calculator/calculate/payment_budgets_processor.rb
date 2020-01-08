class BudgetsCalculator::Calculate::PaymentBudgetsProcessor < BudgetsCalculator::Calculate::BudgetsProcessor

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
        sub_department_id: payment.department_id,
        amount_attributes: {
            value: payment.amount.value,
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