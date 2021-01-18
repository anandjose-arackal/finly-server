class BudgetManager::BudgetsCalculator::Calculate::PaymentBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(payment)
    trail = BudgetTrail.find_by(entity_type: "Payment", entity_id: payment.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end
    if payment.payment_purpose_id == PaymentPurpose.id_for(:advance_against_purchase_order)
      purchase_order_id = payment.parent_id
      invoice_id = nil
    elsif payment.payment_purpose_id == PaymentPurpose.id_for(:vendor_payment)
      purchase_order_id = nil
      invoice_id = (payment.parent_type == "Invoice" ? payment.parent_id : nil)
    else
      purchase_order_id = nil
      invoice_id = nil
    end

    if payment.parent_type == "BeneficiaryPayment"
      tds_value = payment.parent&.tds_amount&.value.to_f
      paid_amount = payment.parent&.advance_amount&.value.to_f
    else
      tds_value = 0
      paid_amount = 0
    end

    if payment.parent_type == "PurchaseOrder"
      parent_trail = BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: payment.parent.items.first.id)
    elsif payment.parent_type == "Invoice"
      parent_trail = BudgetTrail.find_by(entity_type: "InvoiceLineItem", entity_id: payment.parent.items.first.id)
    end

    self.trail_hash = {
        id: trail_id,
        entity: payment,
        category_id: payment.category_id,
        cost_center_id: payment.cost_center_id,
        vendor_id: (payment.receiving_user_id if payment.receiving_user_type == "YesBankVendor"),
        department_id: payment.department_id,
        location_id: payment.location_id,
        user_id: payment.initiating_user_id,
        date: (parent_trail&.date || payment.date),
        entity_status_id: payment.payment_status_id,
        entity_created_at: (parent_trail&.entity_created_at || payment.created_at),
        entity_submitted_at: (parent_trail&.entity_submitted_at || payment.bank_payment_request&.submitted_at || DateUtils.local_date_time),
        payment_purpose_id: payment.payment_purpose_id,
        purchase_order_id: purchase_order_id,
        invoice_id: invoice_id,
        tds_value: tds_value,
        paid_amount_after_tax_value: paid_amount,
        effective_paid_amount_before_tax_value: paid_amount,
        amount_attributes: {
            id: trail&.amount&.id,
            value: payment.amount.value,
            currency_id: payment.amount.currency_id
        },
        amount_before_tax_attributes: {
            id: trail&.amount_before_tax&.id,
            value: payment.amount_before_tax,
            currency_id: payment.amount.currency_id
        },
        amount_after_tax_attributes: {
            id: trail&.amount_after_tax&.id,
            value: payment.amount_after_tax,
            currency_id: payment.amount.currency_id
        }
    }
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(payment)
    budget_trail = BudgetTrail.find_by(entity_type: "Payment", entity_id: payment.id)
    budget_trail&.destroy
  end
end