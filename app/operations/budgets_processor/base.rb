class BudgetsProcessor::Base < BaseOperation
  attr_accessor :budgets, :budget_details
  def init
    self.budgets = []
    self.budget_details = []

  end


  def process
    budgets.each do |budget|
      if budget.budgetable_type == 'User'
        op = ::BudgetsProcessor::Calculate::User.(user, {budget: budget})
      elsif budget.budgetable_type == 'Category'
        op = ::BudgetsProcessor::Calculate::Category.(user, {budget: budget})
      elsif budget.budgetable_type == 'YesBankVendor'
        op = ::BudgetsProcessor::Calculate::YesBankVendor.(user, {budget: budget})
      elsif budget.budgetable_type == 'FieldDropDownItem'
        op = ::BudgetsProcessor::Calculate::FieldDropDownItem.(user, {budget: budget})
      elsif budget.budgetable_type == 'CostCenter'
        op = ::BudgetsProcessor::Calculate::CostCenter.(user, {budget: budget})
      end

      self.budget_details.push(op.result)

    end
  end

  def success
    params[:budget_details] = self.budget_details
    BudgetsProcessor::Base::BasePresenter.new(user, params, messages)
  end

  class BudgetsProcessor::Base::BasePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets

    def init
      self.budgets = params[:budget_details]
    end
  end
end