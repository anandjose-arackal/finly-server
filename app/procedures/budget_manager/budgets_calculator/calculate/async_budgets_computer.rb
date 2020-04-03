class BudgetManager::BudgetsCalculator::Calculate::AsyncBudgetsComputer < Transactions::API

  attr_accessor :budgets

  include Events::Consumer

  consumes_event! 'purchase_order.update', 'purchase_order.create', 'purchase_order.destroy'
  consumes_event! 'invoice.update', 'invoice.create', 'invoice.destroy'
  consumes_event! 'report.update', 'report.create', 'report.destroy', 'expense.update', 'expense.create', 'expense.destroy'
  consumes_event! 'bank_payment_request.update', 'bank_payment_request.create', 'bank_payment_request.destroy'
  consumes_event! 'purchase_request.create', 'purchase_request.update', 'purchase_request.destroy'

  def work(user, payload)
    self.class.(params: payload, current_user: user)
  end

  step :retrieve_applicable_budgets!

  step :recalculate_applicable_budgets!

  def retrieve_applicable_budgets!(options, params:, **)
    document = params[:record]
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: document, current_user: User.first})
    self.budgets = op["result"][:budgets]
  end

  def recalculate_applicable_budgets!(options, params:, **)
    self.budgets.each do |budget|
      op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
    end
  end
end