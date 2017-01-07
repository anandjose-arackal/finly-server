json.extract! report, :id, :name, :submitted_at
json.status do
  json.id report.report_status_id
  json.name result.status_name(report)
end
json.user do
  json.id report.user_id
  json.name report.user.name
end
json.policy do
  json.id report.policy_id
  json.name report.policy.name rescue nil
end
json.expenses_count report.expenses.count
json.dates report.date_as_string
json.total_amount do
  json.value report.total_amount
  json.currency do
    json.extract! Currency.first, :id, :country, :country_code, :symbol
  end
end