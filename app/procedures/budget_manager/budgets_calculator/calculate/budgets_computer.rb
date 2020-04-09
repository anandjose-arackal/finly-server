# this vanilla operation will be called with Name.({"budget": budget})
# which will make the budgets object available inside the options hash

class BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer < Transactions::API


  attr_accessor :budget, :budget_trails, :budget_consumption,
                :amount_to_be_considered, :date_to_be_considered

  include Events::Consumer

  consumes_event! 'budget.update'

  def work(user, payload)
    self.class.(params: payload, current_user: user)
  end

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

  def initialize!(options, **)
    self.budget = (options[:budget] || options[:params][:record]) rescue nil
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
                 .without_invoice_or_po
                 .with_departments_or_sub_departments(department_ids).with_locations(location_ids)
                 .with_categories(category_ids).with_cost_centers(cost_center_ids).with_users(user_ids)
                 .with_budgetable_entities(budgetable_entities)

    true
  end

  # here we calculate the various buckets
  def calculate_buckets!(options, **)
    calculate_buckets = options[:calculate_buckets]
    if calculate_buckets and self.budget.active
      # setting the respective keys to look for in the BudgetTrail model for PO Items and Invoices respectively
      case amount_to_be_considered
      when :amount_after_tax
        po_item_amount_to_be_considered = "remaining_amount_after_tax_value"
        invoice_item_amount_to_be_considered = "billed_amount_after_tax_value"
        paid_amount_to_be_considered = "paid_amount_after_tax_value"
        payment_processing_amount_to_be_considered = "payment_processing_amount_after_tax_value"
        cn_adjusted_amount_to_be_considered = "cn_adjusted_amount_after_tax_value"
      when :amount_before_tax
        po_item_amount_to_be_considered = "remaining_amount_before_tax_value"
        invoice_item_amount_to_be_considered = "billed_amount_before_tax_value"
        paid_amount_to_be_considered = "effective_paid_amount_before_tax_value"
        payment_processing_amount_to_be_considered = "payment_processing_amount_before_tax_value"
        cn_adjusted_amount_to_be_considered = "cn_adjusted_amount_before_tax_value"
      end

      # calculating pending amount - PurchaseRequests that are approved or auto approved and POs that are everything below approved will come under pending
      pending_amount = self.budget_trails.with_entity_type("PurchaseRequestItem").with_entity_status_id(PurchaseRequestStatus.ids_for(:awaiting_approval, :approved, :auto_approved))
                           .joins(self.amount_to_be_considered).sum(:value)

      pending_amount += self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.status_ids_for_pending_bucket).sum("#{po_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered}")

      pending_amount += self.budget_trails.with_entity_type("Expense").with_entity_status_id(ReportStatus.ids_for_pending_bucket).joins(self.amount_to_be_considered).sum(:value)


      # calculating committed amount - PurchaseOrderItems that are above approved status, and InvoiceLineItems that are not everything below approved status

      committed_amount = self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.status_ids_for_committed_bucket).sum("#{po_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered}")

      # this is so that RCM enabled item's taxes remain in the committed bucket
      if amount_to_be_considered == :amount_after_tax
        committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_committed_bucket).sum("#{invoice_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered} - #{cn_adjusted_amount_to_be_considered}")
        committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_pending_payment_bucket).sum("#{invoice_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered} - #{cn_adjusted_amount_to_be_considered}")
        committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").sum("rcm_tax_value")
      else
        committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_committed_bucket).sum("#{invoice_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered} - #{cn_adjusted_amount_to_be_considered}")
        committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_pending_payment_bucket).sum("#{invoice_item_amount_to_be_considered} - #{paid_amount_to_be_considered} - #{payment_processing_amount_to_be_considered} - #{cn_adjusted_amount_to_be_considered}")
        # committed_amount += self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_tds_in_committed_bucket).sum("tds_value")
      end

      committed_amount += self.budget_trails.with_entity_type("Expense").with_entity_status_id(ReportStatus.ids_for_pending_payment_bucket).joins(self.amount_to_be_considered).sum(:value)

      # this is so that the committed amount includes TDS values from beneficiary payments also
      committed_amount += self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.all_except_failed).sum('tds_value')

      pending_payment_amount = 0

      # calculating all payments that are yet to be approved or credited. All except the final completed status of the payment shows here
      # To do this we are going to rely on the invoice line items, purchase order items, and expenses budget trails to tell us the paid amount
      # that would have been proportionately divided among the various line items
      payment_processing_amount = self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_payment_processing_bucket).sum(payment_processing_amount_to_be_considered)
      payment_processing_amount += self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.ids_for_payment_processing_bucket).sum(payment_processing_amount_to_be_considered)
      # TODO - add money request items here after they have been completely implemented

      payment_processing_amount += self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.ids_for_payment_processing_bucket).without_invoice_or_po
                                      .joins(self.amount_to_be_considered).sum('amounts.value')



      # Paid amount will be calculated from the paid amount attribute inside the PO Item, Invoice and Expense budget trails,
      # because that is calculated keeping in mind the various ways in which partial payments can be made
      # You can find the callbacks that handle that inside the payment model - look for method `calculate_paid_amount_in_parent_trails`
      paid_amount = self.budget_trails.with_entity_type("InvoiceLineItem").with_entity_status_id(InwardInvoiceStatus.ids_for_paid_amount_consideration).sum(paid_amount_to_be_considered)
      paid_amount += self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.ids_for_payment_processing_bucket).sum(paid_amount_to_be_considered)

      # this is for POs that have been revised bu haven't had the chance to get approved yet
      paid_amount += self.budget_trails.with_entity_type("PurchaseOrderItem").with_entity_status_id(PurchaseOrderStatus.status_ids_for_pending_bucket).sum(paid_amount_to_be_considered)

      # first is for all expenses that were reimbursed through Finly, and hence will have a "paid_amount_..." value that would have been created from the callback inside payments
      # paid_amount += self.budget_trails.with_entity_type("Expense").with_entity_status_id(ReportStatus.ids_for_paid_bucket).sum(paid_amount_to_be_considered)
      # the second is for all expenses that are paid / settled / closed outside of Finly - we look for all cases where "paid_amount_..." is 0 and sum the expense amounts
      paid_amount += self.budget_trails.with_entity_type("Expense").with_entity_status_id(ReportStatus.ids_for_paid_bucket).joins(self.amount_to_be_considered).sum(:value)

      # TODO - add money request items once they have been completely implemented

      paid_amount += self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.ids_for_paid_bucket).without_invoice_or_po
                         .joins(self.amount_to_be_considered).sum('amounts.value')

      paid_amount += self.budget_trails.with_entity_type("Payment").with_entity_status_id(PaymentStatus.all_except_failed).without_invoice_or_po
                         .sum(paid_amount_to_be_considered)

      total_consumed_amount = (pending_amount + committed_amount + pending_payment_amount + payment_processing_amount + paid_amount)

      remaining_amount = self.budget.budget_amount&.value - (pending_amount + committed_amount + pending_payment_amount + payment_processing_amount + paid_amount)

      if remaining_amount < 0
        remaining_amount = 0
      end

      # TODO - once we combine both committed and penidng payment bucket the below code can be removed
      # the below essentially takes care of an edge case that occurs when there is a PO advance against
      # a procurement and we invoice an amount greater than the advance from a PO. It leads to negative committed amounts and some nasty shit
      # if committed_amount < 0
      #   pending_payment_amount = pending_payment_amount + committed_amount
      #   committed_amount = 0
      # end

      self.budget_consumption.assign_attributes(
                                 budget_amount_attributes: {
                                     id: self.budget_consumption.budget_amount_id,
                                     value: self.budget.budget_amount&.value
                                 },
                                 pending_amount_attributes: {
                                     id: self.budget_consumption.pending_amount_id,
                                     value: pending_amount
                                 },
                                 committed_amount_attributes: {
                                     id: self.budget_consumption.committed_amount_id,
                                     value: committed_amount
                                 },
                                 pending_payment_amount_attributes: {
                                     id: self.budget_consumption.pending_payment_amount_id,
                                     value: pending_payment_amount
                                 },
                                 payment_processing_amount_attributes: {
                                     id: self.budget_consumption.payment_processing_amount_id,
                                     value: payment_processing_amount
                                 },
                                 paid_amount_attributes: {
                                     id: self.budget_consumption.paid_amount_id,
                                     value: paid_amount
                                 },
                                 remaining_amount_attributes: {
                                     id: self.budget_consumption.remaining_amount_id,
                                     value: remaining_amount
                                 },
                                 total_consumed_amount_attributes: {
                                     id: self.budget_consumption.total_consumed_amount_id,
                                     value: total_consumed_amount
                                 }
      )

      # also assigning the spent amount for a budget in the budget model
      self.budget.assign_attributes(
                     spent_amount_attributes: {
                         id: self.budget.spent_amount_id,
                         value: total_consumed_amount,
                         currency_id: 1
                     }
      )
    end
    true
  end

  def persist_buckets!(options, **)
    unless self.budget_consumption.save
      add_message(options, :error, :budget_consumption, "The budget consumption could not be saved because #{self.budget_consumption.errors.full_messages.to_sentence}")
      return false
    end
    unless self.budget.save
      add_message(options, :error, :budget, "Spent amount could not be saved")
      return false
    end
    return true
  end

  def prepare_budgetable_entities!(options, **)
    calculate_trail_items = options[:calculate_trail_items]
    result = {}
    if calculate_trail_items
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
          purchase_order_items: purchase_order_items,
          budget_trails: self.budget_trails
      }
    end
    # adding all the above data so that the items can be accessed outside this operation
    options["result"] = result
  end

end