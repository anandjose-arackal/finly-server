class RemovePersonalCategory < ActiveRecord::Migration[4.2]
  def change
    # changing the category of all expenses that were originally 'Personal'
    Expense.unscoped.all.each do |expense|
      if expense.category.name == "Personal"
        other_category_id = expense.user.company.categories.with_name("Other")&.first&.id
        expense.update_attribute(:category_id, other_category_id)
      end
    end

    # moving money request items that belong to 'Personal' to 'Other'
    MoneyRequestItem.unscoped.all.each do |item|
      if item.category.name == 'Personal'
        other_category_id = item.money_request.user.company.categories.with_name('Other')&.first&.id
        other_item = item.money_request.items.where(category_id: other_category_id)&.first
        other_item.amount.value += item.amount.value
        other_item.save
        item.destroy
      end
    end

    ExpenseRule.unscoped.all.each do |rule|
      if rule.category&.name == 'Personal'
        rule.destroy
      end
    end

    BudgetRule.unscoped.all.each do |rule|
      if rule.category&.name == 'Personal'
        rule.destroy
      end
    end

    Category.all.each do |category|
      if category.name == 'Personal'
        category.destroy
      end
    end

  end
end
