class Personalizer::Adapters::Company118::Procurements118::PurchaseOrders118::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order, :budgets
  def init
    self.purchase_order = op_instance.purchase_order

    op = BudgetsCalculator::RelevantBudgets.(user, object: self.purchase_order)
    if op.success?
      self.budgets = op.budget_data
    end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    budgets.each do |budget|
      budget_amount = budget[:budget].budget_amount.value
      budget_spent_amount = budget[:spent_amount]

      # now adding the above spent amount with the current POs amount to get
      # an idea of how much of the amount will be spent altogether
      # processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget[:budget])
      # if self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected? || self.purchase_order.voided?
      #   po_line_items = processor_instance.relevant_items(self.purchase_order)
      #   if po_line_items.present?
      #     current_object_amount = po_line_items.joins(:total_amount).sum(:value)
      #     spent_amount = budget_spent_amount + current_object_amount
      #   else
      #     spent_amount = budget_spent_amount
      #   end
      # else
      #   spent_amount = budget_spent_amount
      # end
      spent_amount = budget_spent_amount

      if spent_amount > budget_amount
        add_message :error, "Purchase Order Amount exceeding Budget - #{budget[:budget].name}"
      end
    end

    if messages[:error].present?
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end

end