class BudgetsProcessor::Report < BudgetsProcessor::Base
  attr_accessor :report
  def init
    super

    self.report = params[:report]
    self.budgets += Budget.with_budgetable_user_id(report.user.id)
    expenses = self.report.expenses

    expenses.each do |expense|

      self.budgets += Budget.with_budgetable_category_id(expense.category.id)

      expense_type_name = expense.expense_type_name.downcase.gsub(' ', '_') + '_expense'
      self.budgets += get_budgets_from_expense_type(expense, expense_type_name)

    end
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

end