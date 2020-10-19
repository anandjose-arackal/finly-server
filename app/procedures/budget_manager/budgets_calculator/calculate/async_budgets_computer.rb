class BudgetManager::BudgetsCalculator::Calculate::AsyncBudgetsComputer < Transactions::API

  attr_accessor :budgets

  include Events::Consumer

  consumes_event! 'purchase_orders.update', 'purchase_orders.create', 'purchase_orders.destroy'
  consumes_event! 'invoices.update', 'invoices.create', 'invoices.destroy'
  consumes_event! 'reports.update', 'reports.create', 'reports.destroy', 'expenses.update', 'expenses.create', 'expenses.destroy'
  consumes_event! 'bank_payment_requests.update', 'bank_payment_requests.create', 'bank_payment_requests.destroy'
  consumes_event! 'purchase_requests.create', 'purchase_requests.update', 'purchase_requests.destroy'

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