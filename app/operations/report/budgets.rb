class Report::Budgets < BaseOperation
  attr_accessor :report, :budgets, :budget_details

  def init
    self.budgets = []
    self.report = params[:report]
    self.budget_details = []


    self.budgets += Budget.with_budgetable_user_id(report.user.id)
    expenses = self.report.expenses

    expenses.each do |expense|
      self.budgets += Budget.with_budgetable_category_id(expense.category.id)
    end
  end

  def process
    budgets.each do |budget|
      if budget.budgetable_type == 'User'
        op = ::Budgets::Calculate::User.(user, {budget: budget})
      elsif budget.budgetable_type == 'Category'
        op = ::Budgets::Calculate::Category.(user, {budget: budget})
      # elsif budget.budgetable_type == 'Vendor'
      #   result = ::Budgets::Calculate::Vendor.(user, {budget: budget})
      end

      self.budget_details.push(op.result)

    end
  end

  def success
    params[:budget_details] = self.budget_details
    Report::Budgets::BudgetsPresenter.new(user, params, messages)
  end


  class Report::Budgets::BudgetsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets

    def init
      self.budgets = params[:budget_details]
    end
  end
end