json.expenses do
  json.array! @expenses do |expense_op|
    json.extract! expense_op.expense, :id, :note, :merchant_name, :user_id, :user_name, :category_name, :category_id, :expense_type_id,
                  :transcribed, :reimbursable, :report_status, :split_link, :from_cash_on_hand, :synced_with_quickbooks,
                  :expense_tax_type_id, :gst_type_id, :gst_percentage, :tds_slab_id, :usage_date_type, :usage_date_start, :usage_date_end
    json.usage_date_start DateUtils.date_formatted expense_op.expense.usage_date_start
    json.usage_date_end DateUtils.date_formatted expense_op.expense.usage_date_end
    if expense_op.expense.category.parent.present?
      json.parent_category_name expense_op.expense.category.parent.name
      json.parent_category_id expense_op.expense.category.parent.id
    end


    if expense_op.expense.spent_from.present?
      json.pocket do
        json.pocket_name expense_op.expense.spent_from&.name
        json.pocket_id expense_op.expense.spent_from&.id
        json.pocket_balance expense_op.expense.spent_from&.name
      end
    end

    json.cash_pockets expense_op.cash_pockets

    if expense_op.expense.report.present?
      json.report_id expense_op.expense.report_id
    end

    json.distance do
      if expense_op.expense.distance_expense?
        json.type expense_op.expense.distance_expense&.type
        json.value expense_op.expense.distance_value
        json.maps_distance_value expense_op.expense.maps_distance_value

        json.vehicle_rate expense_op.expense.distance_expense.vehicle_rate
        json.distance_rate expense_op.expense.distance_expense.distance_rate
        json.distance_unit expense_op.expense.distance_expense.distance_unit

        json.odometer_reading_start expense_op.expense.distance_expense&.odometer_reading_start
        json.odometer_reading_end expense_op.expense.distance_expense&.odometer_reading_end
        json.odometer_reading_receipt_start expense_op.start_receipt
        json.odometer_reading_receipt_end expense_op.end_receipt
      end
    end

    json.time do
      json.value expense_op.expense.time_value
      json.rate_value expense_op.expense.time_rate_value
    end

    json.vehicle_rates expense_op.vehicle_rates

    json.per_diem do
      json.name expense_op.expense.per_diem_name
      json.rate_value expense_op.expense.per_diem_rate_value
      json.quantity_value expense_op.expense.per_diem_quantity_value
    end

    json.date expense_op.expense.date.strftime("%d %b %Y")
    json.formatted_date expense_op.expense.date.strftime("%Y-%m-%d")

    json.amount do
      json.partial! 'shared/amount', amount: expense_op.expense.original_amount
    end
    json.reimbursable_amount do
      json.partial! 'shared/amount', amount: expense_op.expense&.reimbursable_amount
    end

    json.tds_slab do
      json.id expense_op.expense.tds_slab&.id
      json.name expense_op.expense.tds_slab&.name
      json.tds expense_op.expense.tds_slab&.tds
    end

    json.converted_amount do
      json.partial! 'shared/amount', amount: expense_op.expense.base_amount
    end

    json.converted expense_op.expense.converted?
    json.conversion_rate expense_op.expense.conversion_rate

    if expense_op.expense.card_expense?
      json.original_merchant_name expense_op.expense.card_expense&.card_transaction&.merchant_name
    end

# flag to show whether a particular expense has been converted or not
    json.converted expense_op.converted

    json.per_diems expense_op.per_diems do |per_diem|
      json.id per_diem.id
      json.name "#{per_diem.configurable.name} - #{per_diem.name}"
      json.rate_value per_diem.rate_value
    end

    json.receipts expense_op.expense.receipts do |receipt|
      json.id receipt.id
      json.image do
        json.file_type receipt.file_format
        json.original receipt.image.url
        json.thumb receipt.image.url(:thumb)
      end
    end

    json.violations expense_op.violation

    json.editable expense_op.editable

    json.show_options expense_op.expense.report.blank? && (params[:view] == 'personal' || params[:view].nil?)

    json.deletable ((params[:view].nil? || params[:view] == 'personal') && expense_op.expense.deletable_expense? && expense_op.expense.report_id.nil?)

    json.reimbursable expense_op.expense.reimbursable

    json.personal expense_op.expense.personal

    json.cancellable expense_op.expense.cancellable?

    json.cancelled expense_op.expense.cancelled?

    json.custom_fields do
      expense = expense_op.expense
      case expense.expense_type_id
        when ExpenseType.id_for(:manual)
          json.array! expense_op.expense.manual_expense.custom_fields
        when ExpenseType.id_for(:card)
          json.array! expense_op.expense.card_expense.custom_fields
        when ExpenseType.id_for(:distance)
          json.array! expense_op.expense.distance_expense.custom_fields
        when ExpenseType.id_for(:time)
          json.array! expense_op.expense.time_expense.custom_fields
        when ExpenseType.id_for(:per_diem)
          json.array! expense_op.expense.per_diem_expense.custom_fields
      end
    end

    json.system_messages do
      json.array!(expense_op.expense.system_messages.pluck(:content))
    end

    if expense_op.expense.card_expense? && expense_op.expense.cancelled?
      json.cancelled_against_transactions do
        json.array!(expense_op.expense.card_expense&.cancelled_against_transactions) do |transaction|
          json.timestamp transaction.transaction_timestamp
          json.amount_value transaction.billing_amount_value
          json.type "Refund"
          json.card_number transaction.serial_id
        end
      end
    end

    if expense_op.expense.distance_expense?
      json.locations expense_op.expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
    end

    json.potential_duplicate expense_op.expense.has_duplicate_expenses?

# sending all the currencies and the respective symbols and codes
    json.currencies do
      json.array!(Currency.all) do |currency|
        json.symbol currency&.symbol
        json.country_code currency&.country_code
        json.id currency&.id
      end
    end

    json.is_split expense_op.expense.is_split?
    json.split_count expense_op.expense.split_count

# Tax Tracking Configuration

    em_tax_tracking = expense_op.expense.user.company.feature_subscription.em_tax_tracking
    json.config do
      json.em_tax_tracking em_tax_tracking
    end
  end
end