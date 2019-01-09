manager_name = @result.manager.name rescue nil
finance_manager_name = @result.finance_manager.name rescue nil
json.manager_name manager_name
json.finance_manager_name finance_manager_name
json.total do
  json.value @result.total
  json.currency do
    json.extract! Currency.first, :id, :country, :country_code, :symbol
  end
end
json.date @result.dates
json.report do
  json.partial! '/mobile/v0/reports/report', report: @result.report, result: @result
end
json.actions do
  json.take_control @result.actions[:take_control].present?
  json.review @result.actions[:approve].present?
  json.unapprove @result.actions[:unapprove].present?
  json.add_expenses @result.actions[:add_expenses].present?
  json.delete @result.actions[:delete].present?
  json.retract @result.actions[:retract].present?
  json.settle @result.actions[:settle].present?
  json.settlement_confirm @result.actions[:settlement_confirm].present?
  json.editable @result.actions[:editable].present?
  json.submit @result.actions[:submit].present?
end
cash_pockets = @result.cash_pockets
json.expenses_group @result.expenses_category_sorted do |item|
  json.extract! item, :section_name, :section_total
  json.expenses item[:expenses] do |expense_item|
    json.partial! '/mobile/v0/expenses/expense', expense: expense_item, cash_pockets: cash_pockets
  end
end
json.comments @result.comments do |comment|
  json.extract! comment, :id, :user_id, :report_id, :report_comment_action_id, :created_at
  json.content comment.generate
  name = nil
  name = comment.user.name if comment.user_id.present?
  json.user_name name
end
json.policies @result.policies, :id, :name
json.violations @result.violations
json.custom_fields do
  json.array! @result.report.custom_fields
end