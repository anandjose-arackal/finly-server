class ExpenseSortedByCategoryFasterToggle < ApplicationToggle
  def enabled?
    feature_flag 'release/expense_sorted_by_category_faster', false
  end
end
