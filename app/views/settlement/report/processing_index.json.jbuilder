json.array! @result.paginated_report_processor_groups do |group|
  json.id group.id
  json.created_by_user group.created_by_user
  json.status group.status
  json.created_at DateUtils.date_formatted group.created_at
  json.scheduled_on DateUtils.date_formatted group.scheduled_at
  json.completed_on DateUtils.date_formatted group.completed_at
  json.total_amount group.total_amount
  json.processed_amount group.processed_amount
  json.source_account_type group.source_account_type
  json.payment_type group.payment_type
  json.payment_mode group.payment_mode
  json.actions @result.actions_for(group)
  user_count = 0
  report_count = 0
  json.user_count group.mapping.count
  json.report_count group.map{|rpg_mapping|  rpg_mapping.reports.count }.inject(:+)
end