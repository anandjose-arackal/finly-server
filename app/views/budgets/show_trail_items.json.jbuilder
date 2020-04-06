expenses = @op["result"][:expenses] || []
payments = @op["result"][:payments] || []
purchase_request_items = @op["result"][:purchase_request_items] || []
purchase_order_items = @op["result"][:purchase_order_items] || []
invoice_items = @op["result"][:invoice_items] || []

# # TODO - change the below code to reflect the actual data
# expenses = Expense.all.reorder(created_at: :desc).limit(10)
# payments = Payment.all.reorder(created_at: :desc).limit(10)
# purchase_request_items = PurchaseRequestItem.all.reorder(created_at: :desc).limit(10)
# purchase_order_items = PurchaseOrderItem.all.reorder(created_at: :desc).limit(10)
# invoice_items = InvoiceLineItem.all.where(parent_type: "Invoice").reorder(created_at: :desc).limit(10)

json.budget_trail_items do
  index = 1
  case params[:type]
  when 'expenses'
    # first will be the list of expenses
    json.expenses do
      json.array!(expenses) do |expense|
        json.merchant expense.merchant_name
        json.user expense.user&.name
        json.category_name expense.category&.name
        json.date expense.date.strftime("%d-%b-%Y")
        json.amount expense.amount&.value
        json.purpose expense.note
        json.index index
        index += 1
      end
    end

  when 'payments'
    # list of payments that need to be processed
    json.payments do
      json.array!(payments) do |payment|
        json.vendor payment.receiving_user&.business_name || payment.receiving_account&.name
        json.category_name payment.category&.name
        json.department payment.department&.name
        json.location payment.location&.name
        json.cost_center payment.cost_center&.name
        json.utr payment.utr
        json.amount payment.amount&.value
        json.date payment.date.strftime("%d-%b-%Y")
        json.index index
        index += 1
      end
    end

  when 'purchase_order_items'
    # list of purchase order items
    json.purchase_order_items do
      json.array!(purchase_order_items) do |purchase_order_item|
        json.item_name purchase_order_item.description
        json.vendor purchase_order_item.purchase_order.vendor&.business_name
        json.cost_center purchase_order_item.purchase_order.cost_center&.name
        json.amount purchase_order_item.total_amount&.value
        json.date purchase_order_item.purchase_order&.created_at&.strftime("%d-%b-%Y")
        json.location purchase_order_item.purchase_order.location&.name
        json.department purchase_order_item.purchase_order.department&.name
        json.sub_department purchase_order_item.purchase_order.sub_department&.name
        json.po_number purchase_order_item.purchase_order.po_number
        json.index index
        index += 1
      end
    end

  when 'invoice_items'
    # list of invoice line items
    json.invoice_items do
      json.array!(invoice_items) do |invoice_line_item|
        json.item_name invoice_line_item.description
        json.vendor invoice_line_item.parent.vendor&.business_name
        json.cost_center invoice_line_item.parent.cost_center&.name
        json.amount invoice_line_item.net_amount&.value
        json.date invoice_line_item.parent.created_at&.strftime("%d-%b-%Y")
        json.location invoice_line_item.parent.location&.name
        json.department invoice_line_item.parent.department&.name
        json.sub_department invoice_line_item.parent&.sub_department&.name
        json.invoice_number invoice_line_item.parent.invoice_number
        json.index index
        index += 1
      end
    end

  when 'purchase_request_items'
    json.purchase_request_items do
      json.array!(purchase_request_items) do |purchase_request_item|
        json.index index
        json.pr_number purchase_request_item.purchase_request.order_number
        json.name purchase_request_item.item&.get_custom_description
        json.location purchase_request_item.purchase_request.location&.name
        json.department purchase_request_item.purchase_request.department&.name
        json.cost_center purchase_request_item.purchase_request.cost_center&.name
        json.amount purchase_request_item.estimated_amount&.value
        json.date purchase_request_item.created_at&.strftime("%d-%b-%Y")
        index += 1
      end
    end
  end
end

json.budget_trail_items_count do
  json.expenses_count expenses.count
  json.payments_count payments.count
  json.purchase_order_items_count purchase_order_items.count
  json.invoice_items_count invoice_items.count
  json.purchase_request_items purchase_request_items.count

  case params[:type]
  when 'expenses'
    json.paginated_entities_count expenses.count
  when 'payments'
    json.paginated_entities_count payments.count
  when 'purchase_order_items'
    json.paginated_entities_count purchase_order_items.count
  when 'invoice_items'
    json.paginated_entities_count invoice_items.count
  when 'purchase_request_items'
    json.paginated_entities_count purchase_request_items.count
  end
end
