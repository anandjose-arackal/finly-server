json.result do
  json.array!(@result.paginated_expenses) do |expense|
    json.extract! expense, :id, :note, :merchant_name, :expense_type_id,
                  :transcribed, :reimbursable, :report_status, :split_link, :from_cash_on_hand, :synced_with_quickbooks,
                  :expense_tax_type_id
    json.user expense.user
    json.usage_dates do
      json.type expense.usage_date_type
      json.start DateUtils.date_formatted expense.usage_date_start
      json.end DateUtils.date_formatted expense.usage_date_end
    end
    if expense.category.parent.present?
      json.parent_category do
        json.id expense.category.parent.id
        json.name expense.category.parent.name
      end
    end

    if expense.spent_from.present?
      json.pocket do
        json.name expense.spent_from&.name
        json.id expense.spent_from&.id
        json.balance expense.spent_from&.name
      end
    end

    if expense.report.present?
      json.report_id expense.report_id
    end

    json.distance do
      if expense.distance_expense?
        json.type expense.distance_expense&.type
        json.value expense.distance_value
        json.maps_distance_value expense.maps_distance_value

        json.vehicle_rate expense.distance_expense.vehicle_rate
        json.distance_rate expense.distance_expense.distance_rate
        json.distance_unit expense.distance_expense.distance_unit

        json.odometer_reading do
          json.start expense.distance_expense&.odometer_reading_start
          json.end expense.distance_expense&.odometer_reading_end
        end
      end
    end

    json.time do
      json.value expense.time_value
      json.rate_value expense.time_rate_value
    end

    json.per_diem do
      json.name expense.per_diem_name
      json.rate_value expense.per_diem_rate_value
      json.quantity_value expense.per_diem_quantity_value
    end

    json.date expense.date.strftime("%d %b %Y")
    json.formatted_date expense.date.strftime("%Y-%m-%d")

    json.amount do
      json.partial! 'shared/amount', amount: expense.original_amount
    end
    json.reimbursable_amount do
      json.partial! 'shared/amount', amount: expense&.reimbursable_amount
    end

    json.tds_slab do
      json.id expense.tds_slab&.id
      json.name expense.tds_slab&.name
      json.tds expense.tds_slab&.tds
    end

    json.converted_amount do
      json.partial! 'shared/amount', amount: expense.base_amount
    end

    json.converted expense.converted?
    json.conversion_rate expense.conversion_rate

    if expense.card_expense?
      json.original_merchant_name expense.card_expense&.card_transaction&.merchant_name
    end

# flag to show whether a particular expense has been converted or not
    json.converted @result.converted

    json.per_diems @result.per_diems do |per_diem|
      json.id per_diem.id
      json.name "#{per_diem.configurable.name} - #{per_diem.name}"
      json.rate_value per_diem.rate_value
    end

    json.receipts expense.receipts do |receipt|
      json.id receipt.id
      json.image do
        json.file_type receipt.file_format
        json.original receipt.image.url
        json.thumb receipt.image.url(:thumb)
      end
    end

    # json.violations @result.violation
    json.reimbursable expense.reimbursable
    json.personal expense.personal
    json.cancellable expense.cancellable?
    json.cancelled expense.cancelled?

    json.custom_fields do
      expense = expense
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

    json.system_messages do
      json.array!(expense.system_messages.pluck(:content))
    end

    if expense.card_expense? && expense.cancelled?
      json.cancelled_against_transactions do
        json.array!(expense.card_expense&.cancelled_against_transactions) do |transaction|
          json.timestamp transaction.transaction_timestamp
          json.amount_value transaction.billing_amount_value
          json.type "Refund"
          json.card_number transaction.serial_id
        end
      end
    end

    if expense.distance_expense?
      json.locations expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
    end

    json.potential_duplicate expense.has_duplicate_expenses?

    json.is_split expense.is_split?
    json.split_count expense.split_count

# Tax Tracking Configuration

    em_tax_tracking = expense.user.company.feature_subscription.em_tax_tracking
    json.config do
      json.em_tax_tracking em_tax_tracking
    end

# Tax details for this expense
    json.tax_details do
      json.merchant_gstin expense.gstin_location&.gstin
      json.merchant_state_id expense.gstin_location&.state_id
      json.merchant_registered_name expense.gstin_location&.gstin_master&.legal_name_of_business
      json.tax_amount expense.gst_amount&.value
      json.gst_type_id expense.gst_type_id
      json.merchant_bill_no expense.merchant_bill_no
      json.hsn_sac expense.hsn_sac
      json.state_of_expense_id expense.state_of_expense_id
      json.tax_rate_id expense.tax_rate_id
      json.gstin_location_id expense.gstin_location_id
    end
  end
end
json.count @result.count