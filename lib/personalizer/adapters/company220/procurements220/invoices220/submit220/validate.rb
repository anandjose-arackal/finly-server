class Personalizer::Adapters::Company220::Procurements220::Invoices220::Submit220::Validate < Personalizer::Adapters::Base
  attr_accessor :invoice, :purchase_order, :procurement, :budgets

  def init
    self.invoice = op_instance.invoice
    self.procurement = self.invoice.procurement
    self.purchase_order = self.procurement&.purchase_order
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.invoice, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end
  end

  def process
    # adding logic for checking if budget is being exceeded
    if self.invoice.procurement&.non_po_procurement?
      budget_exceeded = false
      sleep 0.5   # NOTE: There is a race condition between updating accessing total_consumed_amount value
      self.budgets.each do |budget|
        budget_criteria = budget.budget_group_criterium
        budget_amount = budget.budget_consumption&.budget_amount&.value
        budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

        spent_amount = budget_spent_amount

        if spent_amount > budget_amount or budget_amount == 0
          budget_exceeded = false
          add_message :error,  "Invoice Amount exceeding Budget - #{budget_criteria.name}"
        end
      end

      # adding overall message to the user
      if budget_exceeded
        add_message :error, 'Please contact finance to allocate more budget'
      end
    end
  end
end