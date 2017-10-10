json.roles do
  json.admin_summary @result.user.company_admin?
  json.manager_summary (@result.user.finance_manager? or @result.user.manager?)
end
json.admin_summary do
  json.array! @result.admin_summary_mail_configs do |config|
    json.id config.id
    json.period config.period
    json.starting_day_of_month config.starting_day_of_month
    json.scheduled_day_of_month config.scheduled_day_of_month
    json.starting_day_of_week config.starting_day_of_week&.humanize
    json.scheduled_day_of_week config.scheduled_day_of_week&.humanize
    json.scheduled_time config.scheduled_time
  end
end
json.report_summary do
  json.array! @result.manager_report_summary_mail_configs do |config|
    json.id config.id
    json.period config.period
    json.scheduled_day_of_month config.scheduled_day_of_month
    json.scheduled_day_of_week config.scheduled_day_of_week&.humanize
    json.scheduled_time config.scheduled_time
  end
end
json.money_request_summary do
  json.array! @result.manager_money_request_summary_mail_configs do |config|
    json.id config.id
    json.period config.period
    json.scheduled_day_of_month config.scheduled_day_of_month
    json.scheduled_day_of_week config.scheduled_day_of_week&.humanize
    json.scheduled_time config.scheduled_time
  end
end