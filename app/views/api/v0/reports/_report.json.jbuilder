json.extract! report, :id, :name, :report_status_id, :user_id, :policy_id, :submitted_at
policy_name = report.policy.name if report.policy.present?
json.policy_name policy_name
json.user_name report.user.name
json.company_id report.user.company_id
json.status_name result.status_name(report)
json.auto_submit report.auto_submit