class AvailableExpenseTypePfToggle < ApplicationToggle
  def enabled?
    feature_flag 'pf/available_expense_type_fix', false
  end
end
