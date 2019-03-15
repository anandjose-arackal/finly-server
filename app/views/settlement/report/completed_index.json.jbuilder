json.array! @result.paginated_reports do |report|

  json.extract! report, :id, :policy, :date_as_string
  json.name "#{report.id} - #{report.name}"
  json.submitted_on DateUtils.date_formatted(report.submitted_at)
  json.approved_on DateUtils.date_formatted(report.approved_at)
  json.user do
    json.id report.user_id
    json.name report.user.name
    json.email report.user.email
    json.mobile_number report.user.mobile_number
  end
  json.final_approver do
    final_approver = report.final_approver
    if final_approver.present?
      json.name final_approver.name
      json.email final_approver.email
      json.mobile_number final_approver.mobile_number
    end
  end
  json.payment do
    mapping = report.report_processor_group_mapping
    processor_group = mapping&.processor_group
    processed_by = processor_group&.created_by_user

    json.completed_on DateUtils.datetime_formatted mapping&.completed_at
    json.amount mapping&.amount
    json.payment_type processor_group&.payment_type&.humanize
    json.payment_mode processor_group&.payment_mode

    if processed_by.present?
      json.processed_by do
        json.name processed_by.name
        json.email processed_by.email
        json.mobile_number processed_by.mobile_number
      end
    else
      json.processed_by nil
    end
  end

  currency = Currency.first
  json.reimbursable_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount([:reimbursable]), currency: currency)
  end
  json.total_amount do
    json.partial! 'shared/amount', amount: Amount.new(value: report.total_amount, currency: currency)
  end

end