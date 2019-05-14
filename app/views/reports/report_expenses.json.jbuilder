expenses_sorted_by = params[:expenses_sorted_by] || 'category'
json.expenses_sorted_by expenses_sorted_by
if expenses_sorted_by == 'category'
  sorted_expenses = @result.expenses_category_sorted
elsif expenses_sorted_by == 'date'
  sorted_expenses = @result.expenses_date_sorted
else
  sorted_expenses = @result.expenses_category_sorted
end

json.has_custom_fields @result.has_custom_fields?
json.expense_sections sorted_expenses do |category|
  json.extract! category, :section_name, :section_total
  json.expenses category[:expenses] do |expense|
    json.extract! expense, :id, :merchant_name, :amount_value, :expense_type_id,
                  :distance_value, :distance_rate_value, :time_value, :time_rate_value,
                  :expense_tax_type, :gst_percentage, :tds_percentage, :reimbursable_amount, :usage_date_type#, :usage_date_start, :usage_date_end
    json.usage_date_start DateUtils.date_formatted expense.usage_date_start
    json.usage_date_end DateUtils.date_formatted expense.usage_date_end
    if expense.category.parent.present?
      json.category_name expense.category.parent.name
      json.sub_category expense.category.name
    else
      json.category_name expense.category.name
    end
    if expense.note
      if expense.note.length < 29
        json.note expense.note
      else
        json.note expense.note[0..29] + '...'
      end
    end
    # json.extract! expense, :id, :note
    json.date expense.date.strftime('%d %b %y')
    json.reimbursable expense.reimbursable
    json.from_cash_on_hand expense.from_cash_on_hand
    json.spent_from_name expense.spent_from&.name
    json.synced_with_quickbooks expense.synced_with_quickbooks
    json.violations do
      items = @result.violations[expense.id]
      json.blocking_present (items[:expense_blocking].present? or items[:budget_blocking].present? or items['expense_blocking'].present? or items['budget_blocking'].present?)
      json.warning_present (items[:expense_warning].present? or items[:budget_warning].present? or items['expense_warning'].present? or items['budget_warning'].present?)
      json.items items
    end
    if expense.distance_expense?
      json.locations expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
    end
    json.potential_duplicate expense.has_duplicate_expenses?
    json.custom_fields do
      case expense.expense_type_id
      when ExpenseType.id_for(:manual)
        json.array! expense.manual_expense.custom_fields
      when ExpenseType.id_for(:card)
        json.array! expense.card_expense.custom_fields
      when ExpenseType.id_for(:distance)
        json.array! expense.distance_expense.custom_fields
      when ExpenseType.id_for(:time)
        json.array! expense.time_expense.custom_fields
      when ExpenseType.id_for(:per_diem)
        json.array! expense.per_diem_expense.custom_fields
      end
    end
    json.receipts do
      json.array! expense.receipts do |receipt|
        json.id receipt.id
        json.hard_copy_received receipt.hard_copy_received
        json.image do
          json.file_type receipt.file_format
          json.original receipt.image.url
          json.thumb receipt.image.url(:thumb)
        end
      end
    end

    json.tds_slab do
      json.id expense.tds_slab&.id
      json.tds expense.tds_slab&.tds
    end

    # adding pocket information for an expense
    if expense.spent_from.present?
      json.pocket do
        json.pocket_name expense.spent_from&.name
        json.pocket_id expense.spent_from&.id
        json.pocket_balance expense.spent_from&.name
      end
    end
  end
end

json.receipts @result.expenses do |expense|
  unless expense.receipts.blank? or expense.receipts.first.image.url == '/assets/original/missing.png'
    json.id expense.receipts.first.id
    json.hard_copy_received expense.receipts.first.hard_copy_received
    json.image do
      json.file_type expense.receipts.first.file_format
      json.original expense.receipts.first.image.url
      json.thumb expense.receipts.first.image.url(:thumb)
    end
    # json.url expense.receipts.first.image.url
    # json.file_type expense.receipts.first.file_format
    json.date expense.date.strftime('%d %b %Y')
    json.merchant_name expense.merchant_name
    json.amount_value expense.amount_value
  end
end