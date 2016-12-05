json.partial! '/api/v1/reports/report', report: @result.report
json.manager_name @result.manager.name rescue nil
json.finance_manager_name @result.finance_manager.name rescue nil
json.dates @result.dates
json.actions do
  @result.actions.each do |key, value|
    json.set! key, (value[:url].present? or value[:value].present?)
  end
end
json.sections @result.expenses_category_sorted do |item|
  json.name item[:section_name]
  json.total item[:section_total]
  json.expenses item[:expenses] do |expense_item|
    json.partial! '/api/v1/expenses/expense', expense: expense_item
  end
end
json.comments @result.comments do |comment|
  json.extract! comment, :id, :user_id, :report_id, :report_comment_action_id, :created_at
  json.content comment.generate
  json.user_name comment.user.name rescue nil
end
json.policies @result.policies, :id, :name
json.violations @result.violations