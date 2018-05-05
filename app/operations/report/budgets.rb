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
        result = ::Budgets::Calculate::User.(user, {budget: budget})
      elsif budget.budgetable_type == 'Category'
        result = ::Budgets::Calculate::Category.(user, {budget: budget})
      # elsif budget.budgetable_type == 'Vendor'
      #   result = ::Budgets::Calculate::Vendor.(user, {budget: budget})
      end

      self.budget_details.push(result)

    end
  end
end