class Personalizer::Adapters::Company140::Procurements140::Invoices140::Submit140::Validate < Personalizer::Adapters::Base
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
    if self.purchase_order.present?
      purchase_order_base_amount = 0
      invoice_base_amount = 0

      purchase_order.items.each do |item|
        rate = item.rate
        quantity = item.quantity
        amount = rate * quantity
        purchase_order_base_amount += amount
      end

      invoice.invoice_items.each do |item|
        rate = item.rate
        quantity = item.quantity
        amount = rate * quantity
        invoice_base_amount += amount
      end

      if invoice_base_amount > purchase_order_base_amount
        add_message :error, 'Could not submit invoice. Invoice base amount is greater than purchase order base amount'
      end
    end

      # TODO - change the below logic once the ApplicableBudgets has been fixed
      # adding logic for checking if budget is being exceeded
      # if self.invoice.procurement&.non_po_procurement?
      #   budget_exceeded = false
      #   self.budgets.each do |budget|
      #     budget_amount = budget.budget_consumption&.budget_amount&.value
      #     budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value
      #
      #     spent_amount = budget_spent_amount
      #
      #     if spent_amount > budget_amount
      #       budget_exceeded = false
      #       add_message :error,  "Invoice Amount exceeding Budget - #{budget.name}"
      #     end
      #   end
      #
      #   # adding overall message to the user
      #   if budget_exceeded
      #     add_message :error, 'Please contact finance to allocate more budget'
      #   end
      # end
  end
end