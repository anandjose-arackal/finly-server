class BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :budget, :entity, :company_users,
                :trail_hash

  def initialize(budget = nil)
    self.budget = budget
    # extracting the company's users because this will tell us the entries
    # to consider from the BudgetTrail model
    self.company_users = self.budget.company.users
  end

  # this method will return the totality of the amount spent against this particular budget
  def spent_amount
    categories = self.budget.budgetable_categories
    cost_centers = self.budget.budgetable_cost_centers
    departments = self.budget.budgetable_departments
    locations = self.budget.budgetable_locations
    vendors = self.budget.budgetable_vendors
    # now choosing the entities to which we can apply the budget
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    spent_amount = BudgetTrail.within_date(budget.start_date, budget.end_date).with_users(self.company_users.pluck(:id)).with_vendors(vendors).with_departments(departments).with_locations(locations).with_categories(categories).with_cost_centers(cost_centers).with_budgetable_entities(budgetable_entities)
  end

  # i.e. these are the entities that have consumed this particular budget
  def spent_entities
    categories = self.budget.budgetable_categories
    cost_centers = self.budget.budgetable_cost_centers
    departments = self.budget.budgetable_departments
    locations = self.budget.budgetable_locations
    vendors = self.budget.budgetable_vendors
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO as well as PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment

  end

  def self.save_trail
    if self.trail_hash[:id].present?
      budget_trail = BudgetTrail.find_by(id: self.trail_hash[:id])
      budget_trail.update(self.trail_hash)
    else
      budget_trail = BudgetTrail.new(self.trail_hash)
      budget_trail.save
    end
    # todo - mailer / logger in case the saving or updation fails
  end

  protected

end