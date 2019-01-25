class BudgetsCalculator::Calculate::InvoiceItemsBudgetsProcessor < BudgetsCalculator::Calculate::BudgetsProcessor

  def save_trail(invoice_item)
    trail = BudgetTrail.find_by(entity_type: "InvoiceLineItem", entity_id: invoice_item.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end

    # only if this invoice belongs within a procurement, the invoice data is stored
    invoice = invoice_item.parent
    if invoice.procurement_id.blank?
      return
    end

    # additionally check if this invoice is part of a procurement and if it is, the procurement shouldn't already exist
    procurement_id = invoice_item.parent.procurement_id
    procurement = invoice_item.parent.procurement
    if procurement.purchase_order.present?
      trail_by_procurement = BudgetTrail.find_by(procurement_id: procurement_id)
      trail_by_procurement = BudgetTrail.with_entity_type(["PurchaseOrderItem"]).with_entity_id(procurement.purchase_order.items.pluck(:id)).first if trail_by_procurement.blank?
      # if this already exists, then it means that the budget has already been considered under a purchase order
      if trail_by_procurement.present? && trail_by_procurement.entity_type == "PurchaseOrderItem"
        return
      end
    end

    self.trail_hash = {
        id: trail_id,
        procurement_id: invoice_item.parent.procurement_id,
        entity: invoice_item,
        category_id: invoice_item.inventory_line_item&.category_id,
        cost_center_id: invoice_item.parent.cost_center_id,
        user_id: invoice_item.parent.created_by_user_id,
        location_id: invoice_item.parent.location_id,
        department_id: invoice_item.parent.sub_department_id,
        date: invoice_item.parent.created_at,
        amount_attributes: {
            value: invoice_item.net_amount&.value,
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