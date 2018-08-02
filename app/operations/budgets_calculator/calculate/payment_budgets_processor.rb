class BudgetsCalculator::Calculate::PaymentBudgetsProcessor < BudgetsCalculator::Calculate::BudgetsProcessor

  def self.save_trail(payment)
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
        amount_attributes: {
            value: payment.amount.value,
            currency_id: payment.currency_id
        }
    }
    super()
  end

  def self.destroy_trail(payment)
    budget_trail = BudgetTrail.find_by(entity_type: "Payment", entity_id: payment.id)
    budget_trail&.destroy
  end
end