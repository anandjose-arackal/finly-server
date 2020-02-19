# this vanilla operation will be called with Name.({"budget": budget})
# which will make the budgets object available inside the options hash

class BudgetManager::BudgetsCalculator::BudgetsComputer < Transactions::API


  attr_accessor :budget, :budget_trails, :budget_consumption,
                :amount_to_be_considered, :date_to_be_considered

  step :initialize!

  # below method will retrieve all the trails for a particular
  # budget that will then be computed to calculate the buckets
  # Note that this doesn't separate out the various buckets but simply looks at the
  # criteria that any particular budget is associated with
  step :retrieve_trails!

  # this will compute the various buckets based on the trails that were picked in the previous
  # step. All logic with respect to what each bucket entails will be contained here
  step :calculate_buckets!

  # this will simple persist the budget consumption model based on what was calculated in
  # the previous step
  step :persist_buckets!

  # the below step will retrieve all the relevant entities that are consuming this particular budget
  # along with the various document line items that consume this budget
  step :prepare_budgetable_entities!

  # failure :return_errors!

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
    self.date_to_be_considered = self.budget.budget_date_type.name
    true
  end

  def retrieve_trails!(options, **)
    budget_group_criterium = self.budget.budget_group_criterium
    criterial_mapping = budget_group_criterium.select('budgetable_type, GROUP_CONCAT(DISTINCT budgetable_id SEPARATOR ",") AS budgetable_id_list').group(:budgetable_type).as_json
    category_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Category'}&.first&.dig('budgetable_id_list')&.split(',')
    cost_center_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'CostCenter'}&.first&.dig('budgetable_id_list')&.split(',')
    department_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'Department'}&.first&.dig('budgetable_id_list')&.split(',')
    location_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'BranchLocation'}&.first&.dig('budgetable_id_list')&.split(',')
    vendor_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'YesBankVendor'}&.first&.dig('budgetable_id_list')&.split(',')
    user_ids = criterial_mapping.select {|mapping| mapping['budgetable_type'] == 'User'}&.first&.dig('budgetable_id_list')&.split(',')

    budgetable_entities = []
    budgetable_entities << "Expense" if self.budget.expense
    # adding PO as well as PO Item because both will be considered for the
    budgetable_entities << "PurchaseOrderItem" if self.budget.purchase_order
    budgetable_entities << "InvoiceLineItem" if self.budget.purchase_order
    budgetable_entities << "Payment" if self.budget.payment
    budgetable_entities << "PurchaseRequestItem" if self.budget.purchase_request

    self.budget_trails = BudgetTrail.within_date(self.budget.start_date, self.budget.end_date, self.date_to_be_considered).with_vendors(vendor_ids)
                 .with_departments_or_sub_departments(department_ids).with_locations(location_ids)
                 .with_categories(category_ids).with_cost_centers(cost_center_ids).with_users(user_ids)
                 .with_budgetable_entities(budgetable_entities)
    true
  end

  # here we calculate the various buckets
  def calculate_buckets!(options, **)
    # calculating pending amount - PurchaseRequests that are approved or auto approved and POs that are everything below approved will come under pending
    pending_amount = self.budget_trails.with_entity_type("PurchaseRequestItem").with_entity_status_id(PurchaseRequestStatus.ids_for(:approved, :auto_approved))
                         .joins(self.amount_to_be_considered).sum(:value)

    pending_amount += self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.status_ids_for_pending_bucket)
                          .joins(self.amount_to_be_considered).sum(:value)


    # calculating committed amount - PurchaseOrderItems that are above approved status, and InvoiceLineItems that are not everything below approved status
    # One thing to note here is that when some of the items of aa PO have been billed (i.e. have an invoice created against them) we need to consider only those items
    # which have not yet been moved to an invoice that has been approved
    committed_amount = self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.status_ids_for_committed_bucket).not_billed.joins(self.amount_to_be_considered).sum(:value)

    committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_committed_bucket).joins(self.amount_to_be_considered).sum(:value)


    # calculating pending payment amount - wil include all invoice items that are approved and above, and also all payments that are yet o be credited
    pending_payment_amount = self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_pending_payment_bucket).joins(self.amount_to_be_considered).sum(:value)

    pending_payment_amount += self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.ids_for_pending_payment_bucket).joins(self.amount_to_be_considered).sum(:value)

    # calculating payments that have been credited, but are pending confirmation of credit
    payment_processing_amount = self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.ids_for_payment_processing_bucket)
                                    .joins(self.amount_to_be_considered).sum(:value)

    paid_amount = self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.ids_for_paid_bucket)
                      .joins(self.amount_to_be_considered).sum(:value)

    self.budget_consumption.assign_attributes(
                               pending_amount_attributes: {
                                   id: self.budget_consumption.pending_amount_id,
                                   value: pending_amount
                               },
                               committed_amount_attributes: {
                                   id: self.budget_consumption.committed_amount_id,
                                   value: committed_amount
                               },
                               pending_payment_amount_attributes: {
                                   id: self.budget_consumption.pending_payment_amount,
                                   value: pending_payment_amount
                               },
                               payment_processing_amount_attributes: {
                                   id: self.budget_consumption.payment_processing_amount_id,
                                   value: payment_processing_amount
                               },
                               paid_amount_attributes: {
                                   id: self.budget_consumption.paid_amount_id,
                                   value: paid_amount
                               }
    )
    true
  end

  def persist_buckets!(options, **)
    unless self.budget_consumption.save
      errors.add(:budget_consumption, "The budget consumption could not be saved because #{self.budget_consumption.errors.full_messages.to_sentence}")
      return false
    end
    return true
  end

  def prepare_budgetable_entities!(options, **)
    expenses = Expense.with_id(self.budget_trails.with_entity_type("Expense").pluck(:entity_id))
    purchase_request_items = PurchaseRequestItem.with_id(self.budget_trails.with_entity_type("PurchaseRequestItem").pluck(:entity_id))
    purchase_order_items = PurchaseOrderItem.with_id(self.budget_trails.with_entity_type("PurchaseOrderItem").pluck(:entity_id))
    invoice_items = InvoiceLineItem.with_id(self.budget_trails.with_entity_type("InvoiceLineItem").pluck(:entity_id))
    payments = Payment.with_id(self.budget_trails.with_entity_type("Payment").pluck(:entity_id))
    result = {
        expenses: expenses,
        payments: payments,
        purchase_request_items: purchase_request_items,
        invoice_items: invoice_items,
        purchase_order_items: purchase_order_items
    }
    # adding all the above data so that the items can be accessed outside this operation
    options["result"] = result
  end

end