json.roles do
  json.admin_summary @result.user.company_admin?
  json.manager_summary (@result.user.finance_manager? or @result.user.manager?)
end
json.admin_summary do
  json.array! @result.admin_summary_mail_configs, :id, :period,
              :starting_day_of_month, :scheduled_day_of_month, :starting_day_of_week, :scheduled_day_of_week,
              :scheduled_time
end
json.report_summary do
  json.array! @result.manager_report_summary_mail_configs, :id, :period,
              :scheduled_day_of_month, :scheduled_day_of_week,
              :scheduled_time
end
json.money_request_summary do
  json.array! @result.manager_money_request_summary_mail_configs, :id, :period,
              :scheduled_day_of_month, :scheduled_day_of_week,
              :scheduled_time
end