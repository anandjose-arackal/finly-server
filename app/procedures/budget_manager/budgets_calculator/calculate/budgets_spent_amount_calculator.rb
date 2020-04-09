# this operation will only update the spent amount of a budget as it is a business critical aspect of the operation
# and hence will be calculated synchronously while the more details approach of calculating the buckets will
#
class BudgetManager::BudgetsCalculator::Calculate::BudgetsSpentAmountCalculator < Transactions::API

  attr_accessor :budget, :budget_trails, :budget_consumption,
                :amount_to_be_considered, :date_to_be_considered

  step :initialize!

  # below method will retrieve all the trails for a particular
  # budget that will then be computed to calculate the buckets
  # Note that this doesn't separate out the various buckets but simply looks at the
  # criteria that any particular budget is associated with
  step :retrieve_trails!

  # this will calculate the spent amount of the budget so that the total spent amount can
  # be determined synchronously for determination of submission decisions
  step :calculate_spent_amount!

  # this will simple persist the budget consumption model based on what was calculated in
  # the previous step
  step :persist_buckets!



  def initialize!(options, budget:, **)
    self.budget = budget
    if budget.blank?
      errors.add(:budget, "Budget cannot be blank")
      return false
    end

    self.budget_consumption = self.budget.budget_consumption

    # setting the relevant amount to be considered for this budget
    if self.budget.calculated_before_tax_amount
      self.amount_to_be_considered = :amount_before_tax
    else
      self.amount_to_be_considered = :amount_after_tax
    end

    # setting the relevant date type for this budget
    self.date_to_be_considered = self.budget.budget_date_type&.name || "entity_created_at"
    true
  end


  def retrieve_trails!(options, **)
    budget_group_criterium = self.budget.budget_group_criterium

    category_ids = budget_group_criterium.budgetable_categories.pluck(:id)
    cost_center_ids = budget_group_criterium.budgetable_cost_centers.pluck(:id)
    department_ids = budget_group_criterium.budgetable_departments.pluck(:id)
    location_ids = budget_group_criterium.budgetable_locations.pluck(:id)
    vendor_ids = budget_group_criterium.budgetable_vendors.pluck(:id)
    user_ids = budget_group_criterium.budgetable_users.pluck(:id)

    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO as well as PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "InvoiceLineItem" if (self.budget.purchase_order || self.budget.invoice)
    budgetable_entities << "Payment" if self.budget.payment
    budgetable_entities << "PurchaseRequestItem" if self.budget.purchase_request

    self.budget_trails = BudgetTrail.not_revised.within_date(self.budget.start_date, self.budget.end_date, self.date_to_be_considered).with_vendors(vendor_ids)
                             .with_departments_or_sub_departments(department_ids).with_locations(location_ids)
                             .with_categories(category_ids).with_cost_centers(cost_center_ids).with_users(user_ids)
                             .with_budgetable_entities(budgetable_entities)

    true
  end

end