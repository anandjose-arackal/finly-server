json.budget_trail_items do
  index = 1
  case params[:type]
  when 'expenses'

    # first will be the list of expenses
    json.expenses do
      json.array!(@result.paginated_entities) do |expense|
        json.user_name expense.user&.name
        json.category_name expense.category&.name
        json.date expense.date.strftime("%Y-%B-%d")
        json.amount expense.amount&.value
        json.index index
        index += 1
      end
    end

  when 'payments'

    # list of payments that need to be processed
    json.payments do
      json.array!(@result.paginated_entities) do |payment|
        json.vendor payment.receiving_user&.name
        json.category_name payment.category&.name
        json.department payment.department&.name
        json.amount payment.amount&.value
        json.date payment.date.strftime("%Y-%B-%d")
        json.index index
        index += 1
      end
    end

  when 'purchase_order_items'

    # list of purchase order items
    json.purchase_order_items do
      json.array!(@result.paginated_entities) do |purchase_order_item|
        json.name purchase_order_item.description
        json.cost_center_name purchase_order_item.purchase_order.cost_center&.name
        json.amount purchase_order_item.total_amount&.value
        json.date purchase_order_item.purchase_order.delivery_date
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
      json.array!(@result.paginated_entities) do |invoice_line_item|
        json.name invoice_line_item.description
        json.cost_center_name invoice_line_item.parent.cost_center&.name
        json.amount invoice_line_item.net_amount&.value
        json.date invoice_line_item.parent.date&.strftime("%Y-%B-%d")
        json.location invoice_line_item.parent.location&.name
        json.department invoice_line_item.parent.department&.name
        json.sub_department invoice_line_item.parent&.sub_department&.name
        json.invoice_number invoice_line_item.parent.invoice_number
        json.index index
        index += 1
      end
    end

  end
end

json.budget_trail_items_count do
  json.expenses_count @result.spent_entities[0]&.count
  json.payments_count @result.spent_entities[1]&.count
  json.purchase_order_items_count @result.spent_entities[2]&.count
  json.invoice_items_count @result.spent_entities[3]&.count

  case params[:type]
  when 'expenses'
    json.paginated_entities_count @result.paginated_entities&.count
  when 'payments'
    json.paginated_entities_count @result.paginated_entities&.count
  when 'purchase_order_items'
    json.paginated_entities_count @result.paginated_entities&.count
  when 'invoice_items'
    json.paginated_entities_count @result.paginated_entities&.count
  end 
end
