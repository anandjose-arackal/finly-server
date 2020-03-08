class PopulateOldBudgetTrailsWithNewData

  def self.perform
    # we are now going to populate the old budget trails models with data computed
    # according to the new logic that we have for budgets. All the data is available and
    # we only need to do a computation, so that's what we'll do
    #
    # ###########################################################################
    # FIRST we do it for all PO Line Items
    #
    BudgetTrail.where(entity_type: "PurchaseOrderItem").find_each do |trail|
      purchase_order_item = trail.entity
      next if purchase_order_item.blank?
      trail.update(
          remaining_quantity: purchase_order_item.quantity,
          entity_created_at: purchase_order_item.purchase_order.created_at,
          entity_submitted_at: (purchase_order_item.purchase_order.submitted_at || purchase_order_item.purchase_order.created_at),
          entity_status_id: purchase_order_item.purchase_order.purchase_order_status_id,
          remaining_amount_before_tax_value: purchase_order_item.before_tax_amount,
          remaining_amount_after_tax_value: purchase_order_item.after_tax_amount,
          amount_attributes: {
              id: trail&.amount&.id,
              value: purchase_order_item.total_amount&.value,
              currency_id: purchase_order_item.total_amount&.currency_id
          },
          amount_before_tax_attributes: {
              id: trail&.amount_before_tax&.id,
              value: purchase_order_item.before_tax_amount,
              currency_id: purchase_order_item.total_amount&.currency_id
          },
          amount_after_tax_attributes: {
              id: trail&.amount_after_tax&.id,
              value: purchase_order_item.after_tax_amount,
              currency_id: purchase_order_item.total_amount&.currency_id
          }
      )
    end

    ###############################################################################
    # SECOND we do it for all invoice items
    BudgetTrail.where(entity_type: "InvoiceLineItem").find_each do |trail|
      invoice_item = trail.entity
      next if invoice_item.blank?
      if invoice_item.purchase_order_item_id.present?
        po_item = invoice_item.purchase_order_item
        if invoice_item.inventory_line_item.goods?
          billed_quantity = invoice_item.quantity
          billed_ratio = (billed_quantity / po_item&.quantity.to_f) rescue 1
        else
          billed_ratio = (invoice_item.net_amount&.value.to_f / po_item&.total_amount&.value.to_f) rescue 1
        end

        billed_amount_after_tax = po_item&.after_tax_amount.to_f * billed_ratio
        billed_amount_before_tax = po_item&.before_tax_amount.to_f * billed_ratio
      else
        po_item = nil
        billed_quantity = 0
        billed_amount_after_tax = invoice_item.after_tax_amount
        billed_amount_before_tax = invoice_item.before_tax_amount
      end

      if (InwardInvoiceStatus.ids_for(:approved, :auto_approved, :unpaid, :partially_paid, :paid).include?(invoice_item.parent.invoice_status_id)) || (InwardInvoiceType.status_ids_for_committed_bucket.include?(invoice_item.parent.invoice_type_id))
        billed = true
      else
        billed = false
      end

      po_trail_item = BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: invoice_item.purchase_order_item_id)

      trail.update(
          billed_amount_before_tax_value: billed_amount_before_tax,
          billed_amount_after_tax_value: billed_amount_after_tax,
          billed: billed,
          category_id: invoice_item.category_id,
          po_trail_item_id: po_trail_item&.id,
          entity_status_id: invoice_item.parent.invoice_status_id,
          entity_created_at: invoice_item.parent.created_at,
          entity_submitted_at: (invoice_item.parent.submitted_at || invoice_item.parent.created_at),
          amount_attributes: {
              id: trail&.amount&.id,
              value: invoice_item.after_tax_amount,
              currency_id: invoice_item.net_amount&.currency_id
          },
          amount_before_tax_attributes: {
              id: trail&.amount_before_tax&.id,
              value: invoice_item.before_tax_amount,
              currency_id: invoice_item.net_amount&.currency_id
          },
          amount_after_tax_attributes: {
              id: trail&.amount_after_tax&.id,
              value: invoice_item.after_tax_amount,
              currency_id: invoice_item.net_amount&.currency_id
          }
      )
    end


    #####################################################################################
    # THIRD we do it for the Expense budget trails
    BudgetTrail.where(entity_type: "Expense").find_each do |trail|
      expense = trail.entity
      next if expense.blank?
      trail.update(
          cost_center_id: expense.report.cost_center_id,
          department_id: expense.report.department_id,
          location_id: expense.report.location_id,
          date: expense.date,
          entity_created_at: expense.created_at,
          entity_submitted_at: expense.report&.submitted_at,
          entity_status_id: expense.report&.report_status_id,
          reimbursable: expense.reimbursable,
          billed_amount_before_tax_value: expense.amount_before_tax,
          billed_amount_after_tax_value: expense.amount_after_tax,
          amount_attributes: {
              id: trail&.amount&.id,
              value: expense.amount&.value,
              currency_id: expense.amount&.currency_id
          },
          amount_before_tax_attributes: {
              id: trail&.amount_before_tax&.id,
              value: expense.amount_before_tax,
              currency_id: expense.amount.currency_id
          },
          amount_after_tax_attributes: {
              id: trail&.amount_after_tax&.id,
              value: expense.amount_after_tax,
              currency_id: expense.amount.currency_id
          }
      )
    end

    ##########################################################################################
    # FINALLY we do it for the payments budget trails (going to take a while)

    BudgetTrail.where(entity_type: "Payment").find_each do |trail|
      payment = trail.entity
      next if payment.blank?
      payment.save
      if payment.payment_purpose_id == PaymentPurpose.id_for(:advance_against_purchase_order)
        purchase_order_id = paymnet.parent_id
        invoice_id = nil
      elsif payment.payment_purpose_id = PaymentPurpose.id_for(:vendor_payment)
        purchase_order_id = nil
        invoice_id = (payment.parent_type == "Invoice" ? payment.parent_id : nil)
      else
        purchase_order_id = nil
        invoice_id = nil
      end
      trail.update(
          entity_status_id: payment.payment_status_id,
          entity_created_at: payment.payment_order&.bank_payment_request&.created_at,
          entity_submitted_at: payment.payment_order&.bank_payment_request&.submitted_at,
          payment_purpose_id: payment.payment_purpose_id,
          purchase_order_id: purchase_order_id,
          invoice_id: invoice_id,
          amount_attributes: {
              id: trail&.amount&.id,
              value: payment.amount.value,
              currency_id: payment.amount.currency_id
          },
          amount_before_tax_attributes: {
              id: trail&.amount_before_tax&.id,
              value: payment.amount_value,
              currency_id: payment.amount.currency_id
          },
          amount_after_tax_attributes: {
              id: trail&.amount_after_tax&.id,
              value: payment.amount_value,
              currency_id: payment.amount.currency_id
          }
      )
    end


  end
end