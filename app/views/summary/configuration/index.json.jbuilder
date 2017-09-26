json.roles do
  json.admin @result.user.company_admin?
  json.finance_manager @result.user.finance_manager?
  json.manager @result.user.manager?
end
json.admin do
  json.array! @result.admin_summary_mail_configs, :id, :period,
              :starting_day_of_month, :scheduled_day_of_month, :starting_day_of_week, :scheduled_day_of_week,
              :scheduled_time
end