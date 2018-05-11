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

      expense_type_name = expense.expense_type_name.downcase.gsub(' ', '_') + '_expense'
      self.budgets += get_budgets_from_expense_type(expense, expense_type_name)

    end

  end

  def process
    budgets.each do |budget|
      if budget.budgetable_type == 'User'
        op = ::BudgetsProcessor::Calculate::User.(user, {budget: budget})
      elsif budget.budgetable_type == 'Category'
        op = ::BudgetsProcessor::Calculate::Category.(user, {budget: budget})
      # elsif budget.budgetable_type == 'Vendor'
      #   result = ::BudgetsProcessor::Calculate::Vendor.(user, {budget: budget})
      elsif budget.budgetable_type == 'FieldDropDownItem'
        op = ::BudgetsProcessor::Calculate::FieldDropDownItem.(user, {budget: budget})
      end

      self.budget_details.push(op.result)

    end
  end

  def success
    params[:budget_details] = self.budget_details
    Report::Budgets::BudgetsPresenter.new(user, params, messages)
  end

  def get_budgets_from_expense_type(expense, type)
    cf_budgets = []
    budget_ids = []
    expense.send(type).custom_fields.only_drop_downs.each do |cf|
      field_drop_down_item_id = cf.value.value_id
      if budget_ids.include?(field_drop_down_item_id)
        next
      end
      budget_ids.push(field_drop_down_item_id)
      budgets = Budget.with_budgetable_field_drop_down_item(field_drop_down_item_id)
      cf_budgets += budgets
    end
    cf_budgets.uniq
  end


  class Report::Budgets::BudgetsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budgets

    def init
      self.budgets = params[:budget_details]
    end
  end
end