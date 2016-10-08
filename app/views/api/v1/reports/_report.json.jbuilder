json.extract! report, :id, :name, :submitted_at
json.status do
  json.id report.report_status_id
  json.name report.status_name
end
json.user do
  json.id report.user_id
  json.name report.user.name
end
json.policy do
  json.id report.policy_id
  json.name report.policy.name rescue nil
end