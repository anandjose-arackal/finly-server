class BudgetManager::BudgetsCalculator::Calculate::AsyncBudgetsComputer < Transactions::API

  attr_accessor :budgets

  include Events::Consumer

  consumes_event! 'purchase_order.update', 'purchase_order.create', 'purchase_order.destroy'
  consumes_event! 'invoice.update', 'invoice.create', 'invoice.destroy'
  consumes_event! 'report.update', 'report.create', 'report.destroy', 'expense.update', 'expense.create', 'expense.destroy'
  consumes_event! 'payment.update', 'payment.create', 'payment.destroy'

  def work(user, payload)
    self.class.(params: payload, current_user: user)
  end

  step :retrieve_applicable_budgets!

  step :recalculate_applicable_budgets!

  def retrieve_applicable_budgets!(options, params:, record:, **)
    document = record
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: document, current_user: User.first})
    self.budgets = op["result"][:budgets]
  end

  def recalculate_applicable_budgets!(options, params:, record:, **)
    # TODO
  end
end