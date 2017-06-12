json.partial! '/mobile/v1/reports/report', report: @result.report
manager_name = ''
manager_name = @result.manager.name if @result.manager.present?
finance_manager_name = ''
finance_manager_name = @result.finance_manager.name if @result.finance_manager.present?
json.manager_name manager_name
json.finance_manager_name finance_manager_name
json.total do
  json.value @result.total
  json.currency do
    json.extract! Currency.first, :id, :country, :country_code, :symbol
  end
end
json.date @result.dates
json.actions do
  @result.actions.each do |key, value|
    json.set! key, (value[:url].present? or value[:value].present?)
  end
end
json.sections @result.expenses_category_sorted do |item|
  json.name item[:section_name]
  json.total item[:section_total]
  json.expenses item[:expenses] do |expense_item|
    json.partial! '/mobile/v1/expenses/expense', expense: expense_item
  end
end
json.comments @result.comments do |comment|
  json.extract! comment, :id, :user_id, :report_id, :report_comment_action_id, :created_at
  json.content comment.generate
  json.user_name comment.user.name rescue nil
end
json.policies @result.policies, :id, :name
json.violations @result.violations
json.custom_fields do
  json.array! @result.report.custom_fields
end