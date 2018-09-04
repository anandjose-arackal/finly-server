class BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :budget, :entity, :company_users,
                :trail_hash

  def initialize(budget = nil)
    self.budget = budget
    # extracting the company's users because this will tell us the entries
    # to consider from the BudgetTrail model
    self.company_users = self.budget&.company&.users
  end

  # this method will return the totality of the amount spent against this particular budget
  def spent_amount
    categories = self.budget.budgetable_categories
    cost_centers = self.budget.budgetable_cost_centers
    departments = self.budget.budgetable_departments
    locations = self.budget.budgetable_locations
    vendors = self.budget.budgetable_vendors
    users = self.budget.budgetable_users
    # now choosing the entities to which we can apply the budget
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    spent_amount = BudgetTrail.within_date(budget.start_date, budget.end_date).with_users(self.company_users.pluck(:id)).with_vendors(vendors.pluck(:id)).with_departments(departments.pluck(:id)).with_locations(locations.pluck(:id)).with_categories(categories.pluck(:id)).with_cost_centers(cost_centers.pluck(:id)).with_users(users.pluck(:id)).with_budgetable_entities(budgetable_entities).joins_amount.sum(:value)
  end

  # i.e. these are the entities that have consumed this particular budget
  # will return an array of arrays, that contain expenses, payments, and purchase orders respectively
  def spent_entities
    categories = self.budget.budgetable_categories
    cost_centers = self.budget.budgetable_cost_centers
    departments = self.budget.budgetable_departments
    locations = self.budget.budgetable_locations
    vendors = self.budget.budgetable_vendors
    users = self.budget.budgetable_users
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO as well as PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    payment_ids = BudgetTrail.within_date(self.budget.start_date, self.budget.end_date).with_users(self.company_users.pluck(:id)).with_vendors(vendors.pluck(:id)).with_departments(departments.pluck(:id)).with_locations(locations.pluck(:id)).with_categories(categories.pluck(:id)).with_cost_centers(cost_centers.pluck(:id)).with_users(users.pluck(:id)).with_entity_type("Payment").pluck(:entity_id)
    payments = Payment.with_id(payment_ids)
    expense_ids = BudgetTrail.within_date(self.budget.start_date, self.budget.end_date).with_users(self.company_users.pluck(:id)).with_vendors(vendors.pluck(:id)).with_departments(departments.pluck(:id)).with_locations(locations.pluck(:id)).with_categories(categories.pluck(:id)).with_cost_centers(cost_centers.pluck(:id)).with_users(users.pluck(:id)).with_entity_type("Expense").pluck(:entity_id)
    expenses = Expense.with_id(expense_ids)
    purchase_order_item_ids = BudgetTrail.within_date(self.budget.start_date, self.budget.end_date).with_users(self.company_users.pluck(:id)).with_vendors(vendors.pluck(:id)).with_departments(departments.pluck(:id)).with_locations(locations.pluck(:id)).with_categories(categories.pluck(:id)).with_cost_centers(cost_centers.pluck(:id)).with_users(users.pluck(:id)).with_entity_type("PurchaseOrderItem").pluck(:entity_id)
    purchase_order_items = PurchaseOrderItem.with_id(purchase_order_item_ids)
    [expenses, payments, purchase_order_items]
  end

  def save_trail
    if self.trail_hash[:id].present?
      budget_trail = BudgetTrail.find_by(id: self.trail_hash[:id])
      budget_trail.update(self.trail_hash)
    else
      budget_trail = BudgetTrail.new(self.trail_hash)
      budget_trail.save
    end
    # todo - mailer / logger in case the saving or updation fails
  end

  def destroy_trail

  end

  protected

end