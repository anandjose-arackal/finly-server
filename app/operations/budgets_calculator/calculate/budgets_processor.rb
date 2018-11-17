class BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :budget, :entity, :trail_hash

  def initialize(budget = nil)
    self.budget = budget
  end

  # this method will return the totality of the amount spent against this particular budget
  def spent_amount
    criterial_mapping = self.budget.budget_criteria_mappings.select('budgetable_type, GROUP_CONCAT(DISTINCT budgetable_id SEPARATOR ",") AS budgetable_id_list').group(:budgetable_type).as_json
    category_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Category'}&.first&.dig('budgetable_id_list')&.split(',')
    cost_center_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'CostCenter'}&.first&.dig('budgetable_id_list')&.split(',')
    department_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Department'}&.first&.dig('budgetable_id_list')&.split(',')
    location_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'BranchLocation'}&.first&.dig('budgetable_id_list')&.split(',')
    vendor_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'YesBankVendor'}&.first&.dig('budgetable_id_list')&.split(',')
    user_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'User'}&.first&.dig('budgetable_id_list')&.split(',')

    # now choosing the entities to which we can apply the budget
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "InvoiceLineItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    BudgetTrail.within_date(self.budget.start_date, self.budget.end_date).with_vendors(vendor_ids)
                       .with_departments_or_sub_departments(department_ids).with_locations(location_ids)
                       .with_categories(category_ids).with_cost_centers(cost_center_ids).with_users(user_ids)
                       .with_budgetable_entities(budgetable_entities).joins_amount.sum(:value)
  end

  # i.e. these are the entities that have consumed this particular budget
  # will return an array of arrays, that contain expenses, payments, and purchase orders respectively
  def spent_entities
    criterial_mapping = self.budget.budget_criteria_mappings.select('budgetable_type, GROUP_CONCAT(DISTINCT budgetable_id SEPARATOR ",") AS budgetable_id_list').group(:budgetable_type).as_json
    category_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Category'}&.first&.dig('budgetable_id_list')&.split(',')
    cost_center_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'CostCenter'}&.first&.dig('budgetable_id_list')&.split(',')
    department_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Department'}&.first&.dig('budgetable_id_list')&.split(',')
    location_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'BranchLocation'}&.first&.dig('budgetable_id_list')&.split(',')
    vendor_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'YesBankVendor'}&.first&.dig('budgetable_id_list')&.split(',')
    user_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'User'}&.first&.dig('budgetable_id_list')&.split(',')

    trails = BudgetTrail.within_date(self.budget.start_date, self.budget.end_date).with_vendors(vendor_ids)
                 .with_departments_or_sub_departments(department_ids).with_locations(location_ids)
                 .with_categories(category_ids).with_cost_centers(cost_center_ids).with_users(user_ids)
                 .select('entity_type, GROUP_CONCAT(DISTINCT entity_id SEPARATOR ",") AS entity_id_list').group(:entity_type).as_json
    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO as well as PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "InvoiceLineItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    payment_ids = trails.select {|mapping| mapping['entity_type'] == 'Payment'}&.first&.dig('entity_id_list')&.split(',')
    payments = Payment.with_id(payment_ids)
    expense_ids = trails.select {|mapping| mapping['entity_type'] == 'Expense'}&.first&.dig('entity_id_list')&.split(',')
    expenses = Expense.with_id(expense_ids)
    purchase_order_item_ids = trails.select {|mapping| mapping['entity_type'] == 'PurchaseOrderItem'}&.first&.dig('entity_id_list')&.split(',')
    purchase_order_items = PurchaseOrderItem.with_id(purchase_order_item_ids).include_details
    invoice_item_ids = trails.select {|mapping| mapping['entity_type'] == 'InvoiceLineItem'}&.first&.dig('entity_id_list')&.split(',')
    invoice_items = InvoiceLineItem.with_id(invoice_item_ids)
    [expenses, payments, purchase_order_items, invoice_items]
  end

  # this method will accept either a PO, Invoice, PaymentOrder or Report object and
  # return the relevant items in the object that apply to this particular budget
  def relevant_items(object)
    category_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Category'}&.first&.dig('budgetable_id_list')&.split(',')
    cost_center_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'CostCenter'}&.first&.dig('budgetable_id_list')&.split(',')
    department_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Department'}&.first&.dig('budgetable_id_list')&.split(',')
    location_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'BranchLocation'}&.first&.dig('budgetable_id_list')&.split(',')
    vendor_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'YesBankVendor'}&.first&.dig('budgetable_id_list')&.split(',')
    user_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'User'}&.first&.dig('budgetable_id_list')&.split(',')
    object = object.class.with_department_ids(department_ids).with_location_ids(location_ids).with_vendor_ids(vendor_ids).with_user_ids(user_ids).first
    if object.blank?
      return []
    end
    case object.class.name
      when "PurchaseOrder", "Invoice"
        items = object.items
        items = items.with_category_ids(category_ids).with_cost_center_ids(cost_center_ids)
      when "PaymentOrder", "BankPaymentRequest"
        items = object.payments
        items = items.with_category_ids(category_ids).with_cost_center_ids(cost_center_ids)
      when "Report"
        items = object.expenses
        items = items.with_category_ids(category_ids).with_cost_center_ids(cost_center_ids)
      else
        items = []
    end
    items
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