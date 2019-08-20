json.id @result.report_processor_group.id
json.created_by_user @result.report_processor_group.created_by_user
json.status @result.report_processor_group.status
json.created_at DateUtils.date_formatted @result.report_processor_group.created_at
json.scheduled_on DateUtils.date_formatted @result.report_processor_group.scheduled_at
json.completed_on DateUtils.date_formatted @result.report_processor_group.completed_at
json.total_amount @result.report_processor_group.total_amount
json.processed_amount @result.report_processor_group.processed_amount
json.source_account_type @result.report_processor_group.source_account_type
json.payment_type @result.report_processor_group.payment_type
json.payment_mode @result.report_processor_group.payment_mode
json.actions @result.actions_for(@result.report_processor_group)

