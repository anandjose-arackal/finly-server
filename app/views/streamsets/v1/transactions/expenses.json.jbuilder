json.result do
  json.array!(@result.paginated_expenses) do |expense|
    user = expense.user
    report = expense.report
    json.extract! expense, :id, :note, :merchant_name, :expense_type_id,
                  :transcribed, :reimbursable, :report_status, :split_link, :from_cash_on_hand, :synced_with_quickbooks,
                  :expense_tax_type_id
    json.created_at expense.created_at.strftime("%Y-%m-%d %H:%M:%S")
    json.updated_at expense.updated_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.user expense.user&.json_for_trail({:streamsets => true})
    json.user_employee_id expense.user&.profile&.employee_id
    json.user_cost_center user.cost_center&.name
    json.user_cost_center_code user.cost_center&.cost_center_code
    json.user_location user.location&.name
    json.user_location_code user.location&.location_code
    json.user_department user.department&.name
    json.user_department_code user.department&.department_code
    json.operating_unit expense.user.gl_config[:operation_unit] rescue ''
    json.expense_type expense.expense_type&.name
    json.total_expenses report&.expenses&.count

    json.usage_dates do
      json.type expense.usage_date_type
      json.start DateUtils.date_formatted expense.usage_date_start
      json.end DateUtils.date_formatted expense.usage_date_end
    end

    json.parent_category do
      json.id expense.category&.id
      json.name expense.category&.name
      json.gl_code expense.category&.gl_code
    end

    json.pocket do
      json.name expense.spent_from&.name
      json.id expense.spent_from&.id
      json.balance expense.spent_from&.balance&.value
    end

    json.bank_account do
      # json.merge! expense.user.bank_accounts.where(default_account: true, disabled: false).non_deleted.first.as_json
      json.merge! expense.user.bank_accounts.default_accounts.first.as_json
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

    json.date expense.date.strftime("%Y-%m-%d %H:%M:%S")
    json.formatted_date expense.date.strftime("%Y-%m-%d %H:%M:%S")

    json.amount do
      json.partial! 'shared/amount', amount: expense.original_amount
    end
    json.reimbursable_amount do
      json.partial! 'shared/amount', amount: expense&.reimbursable_amount
    end
    json.total_amount do
      json.partial! 'shared/amount', amount: expense.amount
    end

    json.tds_slab do
      json.id expense.tds_slab&.id
      json.name expense.tds_slab&.name
      json.tds expense.tds_slab&.tds
    end

    json.converted_amount do
      json.partial! 'shared/amount', amount: expense.base_amount
    end

    # flag to show whether a particular expense has been converted or not
    json.converted expense.converted?
    json.conversion_rate expense.conversion_rate

    if expense.card_expense?
      json.original_merchant_name expense.card_expense&.card_transaction&.merchant_name
    end

    json.parent_department do
      json.code expense.user&.department&.department_code
      json.id expense.user&.department&.id
      json.name expense.user.department&.name
    end

    json.parent_cost_center do
      json.code expense.user&.cost_center&.cost_center_code
      json.id expense.user&.cost_center&.id
      json.name expense.user&.cost_center&.name
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

    # json.custom_fields do
    #   expense = expense
    #   case expense.expense_type_id
    #   when ExpenseType.id_for(:manual)
    #     json.array! expense.manual_expense.custom_fields
    #   when ExpenseType.id_for(:card)
    #     json.array! expense.card_expense.custom_fields
    #   when ExpenseType.id_for(:distance)
    #     json.array! expense.distance_expense.custom_fields
    #   when ExpenseType.id_for(:time)
    #     json.array! expense.time_expense.custom_fields
    #   when ExpenseType.id_for(:per_diem)
    #     json.array! expense.per_diem_expense.custom_fields
    #   end
    # end

    custom_fields = expense.custom_fields.map {|cf| {name: cf.field_configuration.field_name, value: cf.string_value}}
    json.custom_fields custom_fields

    custom_fields.each do |custom_field|
      json.set! custom_field[:name], custom_field[:value]
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
      gst_applicable = expense.category&.gst_applicable
      json.gst_applicable gst_applicable
      json.expense_tax_type (gst_applicable ? expense.expense_tax_type&.name&.humanize : '')
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
      json.gst_percentage (gst_applicable ? expense.gst_percentage : 0)
      json.gst_type (gst_applicable ? expense.gst_type&.name&.humanize&.upcase : nil)
      json.gst_amount (gst_applicable ? expense.gst_amount&.value&.round(2) : 0)
      json.igst_amount (gst_applicable ? (expense.gst_type&.name == 'igst' ? expense.gst_amount&.value : 0) : 0)
      json.cgst_amount ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : 0) : 0) rescue 0)
      json.sgst_amount ((gst_applicable ? (expense.gst_type&.name == 'cgst_sgst' ? ((expense.gst_amount&.value) / 2).round(2) : 0) : 0) rescue 0)
      json.net_total_amount (gst_applicable ? ((expense.amount&.value || 0) - (expense.gst_amount&.value&.round(2) || 0))&.round(2) : expense.amount&.value)
      json.gst_location (gst_applicable ? expense.gstin_location&.location : '')
      json.merchant_state (gst_applicable ? expense.gstin_location&.state&.name : '')
      json.state_of_expense (gst_applicable ? expense.state_of_expense&.name : '')
      json.tax_rate (gst_applicable ? expense.tax_rate&.rate&.to_f : 0)
    end

    # report details
    json.report_id expense.report_id
    json.report_approved_at expense.report&.approved_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.report_created_at expense.report&.created_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.report_note expense.report&.memo
    json.report_bank_reference_number expense.report&.bank_reference_number
    json.report_source_account expense.report&.source_account
    json.report_submitted_at expense.report&.submitted_at&.strftime("%Y-%m-%d %H:%M:%S")
    json.finance_approved_date expense.report&.approved_at&.strftime("%Y-%m-%d %H:%M:%S")


    # exxtra fields
    fm = expense.report.policy.policy_user_roles.where(user_role_id: 2).first&.user
    json.finance_manager "#{fm&.first_name} #{fm&.last_name}"
  end
end
json.count @result.expenses.count