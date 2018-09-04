class BudgetsProcessor::Calculate::FieldDropDownItem < BudgetsProcessor::Calculate::Base
  attr_accessor :field_drop_down_item_id, :field_configuration_id

  def init
    super
    self.field_drop_down_item_id = budget.budgetable_id
  end

  def process
    field_drop_down_selections = FieldDropDownSelection.with_value(field_drop_down_item_id)

    field_drop_down_selection_ids = field_drop_down_selections.pluck(:id)

    custom_fields = CustomField.with_drop_down_selection(field_drop_down_selection_ids).expenses

    # Since custom fields can be associated only to a particular type of expense, all the custom fields will be
    #   belonging to one expense type
    if custom_fields.present?

      expense_type_name = custom_fields[0].parent_type

      # Manual Expense, Card Expense, Distance & PerDiem ids
      expense_w_type_ids = custom_fields.pluck(:parent_id)

      # Expense ids
      expense_ids = expense_type_name.constantize.with_id(expense_w_type_ids).pluck(:expense_id)

      if items_requested
        expenses = Expense.with_id(expense_ids).user_budget_expenses(budget.start_date, budget.end_date).joins(:amount)
        self.spent_amount += expenses.sum(:value)
        self.budget_trail_items += expenses
      else
        self.spent_amount = Expense.with_id(expense_ids).user_budget_expenses(budget.start_date, budget.end_date).joins(:amount).sum(:value)
      end
    else
      self.spent_amount += 0
    end


  end
end