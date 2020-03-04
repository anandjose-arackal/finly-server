class BudgetManager::BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(invoice_item)
    trail = BudgetTrail.find_by(entity_type: "InvoiceLineItem", entity_id: invoice_item.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end

    # only if this invoice belongs within a procurement, the invoice data is stored
    # i.e. if it's an invoice that is created along with a payment for example, it won't be considered
    invoice = invoice_item.parent
    if invoice.procurement_id.blank?
      return
    end

    # # additionally check if this invoice is part of a procurement and if it is, the procurement shouldn't already exist
    # procurement_id = invoice_item.parent.procurement_id
    # procurement = invoice_item.parent.procurement
    # if procurement.purchase_order.present?
    #   trail_by_procurement = BudgetTrail.find_by(procurement_id: procurement_id)
    #   trail_by_procurement = BudgetTrail.with_entity_type(["PurchaseOrderItem"]).with_entity_id(procurement.purchase_order.items.pluck(:id)).first if trail_by_procurement.blank?
    #   # if this already exists, then it means that the budget has already been considered under a purchase order
    #   if trail_by_procurement.present? && trail_by_procurement.entity_type == "PurchaseOrderItem"
    #     return
    #   end
    # end
    #

    # if this an invoice from a PO, a few things need to be sorted out first.
    # Firstly, the amount considered in the invoice item should reduce the proporionate amount consumed from the PO invoice item it is linked to
    # now based on whether it's a good ors service, we have to put the billed_amount_value attribute - which contains the amount we want to consider in the budget
    if invoice_item.purchase_order_item_id.present?
      po_item = invoice_item.purchase_order_item
      if invoice_item.inventory_line_item.goods?
        billed_quantity = invoice_item.quantity
        billed_ratio = (billed_quantity / po_item&.quantity.to_f) rescue 1
      else
        billed_ratio = (invoice_item.net_amount&.value.to_f / po_item.total_amount&.value.to_f) rescue 1
      end

      billed_amount_after_tax = po_item.amount_after_tax * billed_ratio
      billed_amount_before_tax = po_item.amount_before_tax * billed_ratio
    else
      po_item = nil
      billed_quantity = 0
      billed_amount_after_tax = invoice_item.after_tax_amount
      billed_amount_before_tax = invoice_item.before_tax_amount
    end

    if (InwardInvoiceStatus.ids_for_pending_payment_bucket.include?(invoice_item.parent.invoice_status_id))
      billed = true
    else
      billed = false
    end

    # extracting the PO Item's BudgetTrail object here to store the reference, because we need to update
    # this once the invoice is created to adjust the remaining amount and remaining quantity
    po_trail_item = BudgetTrail.find_by(entity_type: "PurchaseOrderItem", entity_id: invoice_item.purchase_order_item_id)

    self.trail_hash = {
        id: trail_id,
        procurement_id: invoice_item.parent.procurement_id,
        entity: invoice_item,
        category_id: invoice_item.inventory_line_item&.category_id,
        cost_center_id: invoice_item.cost_center_id,
        user_id: invoice_item.parent.created_by_user_id,
        location_id: invoice_item.parent.location_id,
        department_id: invoice_item.department_id,
        date: invoice_item.parent.date,
        entity_status_id: invoice_item.parent.invoice_status_id,
        entity_created_at: invoice_item.parent.created_at,
        entity_submitted_at: (invoice_item.parent.submitted_at || invoice_item.parent.created_at),
        vendor_id: invoice_item.parent.vendor_id,
        billed: billed,
        po_trail_item_id: po_trail_item&.id,
        billed_amount_before_tax_value: billed_amount_before_tax,
        billed_amount_after_tax_value: billed_amount_after_tax,
        billed_quantity: invoice_item.quantity,
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
    }
    super()
  end

  def destroy_trail(invoice_item)
    budget_trail = BudgetTrail.find_by(entity_type: "InvoiceLineItem", entity_id: invoice_item.id)
    budget_trail&.destroy
  end
end