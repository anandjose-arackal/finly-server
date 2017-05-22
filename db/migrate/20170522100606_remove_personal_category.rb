class RemovePersonalCategory < ActiveRecord::Migration
  def change
    # changing the category of all expenses that were originally 'Personal'
    Expense.unscoped.all.each do |expense|
      if expense.category.name == "Personal"
        other_category_id = expense.user.company.categories.with_name("Other")&.first&.id
        expense.update_attribute(:category_id, other_category_id)
      end
    end

    # # removing the 'Other' category from the database
    # remove_foreign_key :expenses, column: :category_id

    Category.all.each do |category|
      if category.name == 'Personal'
        category.destroy
      end
    end

    # # adding back the foreign key from expenses to category
    # add_foreign_key :expenses, :categories
  end
end
