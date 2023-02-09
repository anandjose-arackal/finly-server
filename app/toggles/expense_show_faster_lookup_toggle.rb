class ExpenseShowFasterLookupToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/expense_show_faster_lookup', false
  end
end
