class BudgetsProcessor::Calculate::ExpenseAdapter < BudgetsProcessor::BaseAdapter

  def vendors_total
    vendors = budget.budgetable_vendors
    start_date = budget.start_date
    end_date = budget.end_date
    expenses_amount = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(vendor_id: vendors.pluck(:id)).where(entity_type: "Expense").joins_amount.sum(:value)
  end

  def vendors_entity_list
    vendors = budget.budgetable_vendors
    start_date = budget.start_date
    end_date = budget.end_date
    payments_ids = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(vendor_id: vendors.pluck(:id)).where(entity_type: "Expense").pluck(:entity_id)
    expenses = Expense.with_id(payments_ids)
  end

  def categories_total
    categories = budget.budgetable_categories
    start_date = budget.start_date
    end_date = budget.end_date
    expenses_amount = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(category_id: categories.pluck(:id)).where(entity_type: "Expense").joins_amount.sum(:value)
  end

  def categories_entity_list
    categories = budget.budgetable_categories
    start_date = budget.start_date
    end_date = budget.end_date
    payments_ids = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(category_id: categories.pluck(:id)).where(entity_type: "Expense").pluck(:entity_id)
    expenses = Expense.with_id(payments_ids)
  end

  def cost_centers_total
    cost_centers = budget.budgetable_cost_centers
    start_date = budget.start_date
    end_date = budget.end_date
    expenses_amount = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(cost_center_id: cost_centers.pluck(:id)).where(entity_type: "Expense").joins_amount.sum(:value)
  end

  def cost_center_entity_list
    cost_centers = budget.budgetable_cost_centers
    start_date = budget.start_date
    end_date = budget.end_date
    payments_ids = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(cost_center_id: cost_centers.pluck(:id)).where(entity_type: "Expense").pluck(:entity_id)
    expenses = Expense.with_id(payments_ids)
  end

  def location_total
    locations = budget.budgetable_locations
    start_date = budget.start_date
    end_date = budget.end_date
    expenses_amount = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(location_id: locations.pluck(:id)).where(entity_type: "Expense").joins_amount.sum(:value)
  end

  def location_entity_list
    locations = budget.budgetable_locations
    start_date = budget.start_date
    end_date = budget.end_date
    payments_ids = BudgetTrail.where('date >= ? AND date <= ?', start_date, end_date).where(location_id: locations.pluck(:id)).where(entity_type: "Expense").pluck(:entity_id)
    expenses = Expense.with_id(payments_ids)
  end
end