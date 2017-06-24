json.extract! @result.report, :id, :name, :memo, :report_status_id, :auto_submit
json.user_name @result.report.user.name
json.user_initial @result.report.user.name.split(' ').first[0] + ((@result.report.user.name.split(' ')[1][0] rescue nil) or @result.report.user.name.split(' ').first[1])
json.status @result.status_name(@result.report)
json.status_name @result.status_name(@result.report)
manager = (@result.manager.name rescue '')
json.manager_name manager
finance_manager = (@result.finance_manager.name rescue '')
json.finance_manager_name finance_manager
json.export_csv export_report_path(report_id: @result.report.id, view: params[:view], :format => :csv)
json.export_xls export_report_path(report_id: @result.report.id, view: params[:view], :format => :xls)
json.export_pdf export_report_path(report_id: @result.report.id, view: params[:view], :format => :pdf)
json.enforce_policy_enabled @result.report.user.enforce_policy_enabled?
json.deleted @result.report.is_deleted
json.non_reimbursable_expenses_total @result.non_reimbursable_expenses_total
json.reimbursable_expenses_total @result.reimbursable_expenses_total
json.card_expenses_total @result.card_expenses_total
json.currency_symbol @result.report.base_currency_symbol
json.currency_country_code @result.report.base_currency_code

policy_id = nil
policy_name = nil
if @result.report.policy
  policy_id = @result.report.policy_id
  policy_name = @result.report.policy.name
  json.policy @result.report.policy.name
  json.policy_id @result.report.policy_id
end
json.policy policy_name
json.policy_id policy_id

json.policies @result.policies do |policy|
  json.extract! policy, :id, :name
end

json.total @result.report.total_amount
json.base_currency_id @result.report.base_currency_id
json.date @result.report.created_at.strftime('%d %b %Y')

json.comments @result.comments do |comment|
  json.content comment.generate @result.user
  json.created_at comment.created_at.strftime('%d %b %Y')
  comment_u_id = nil
  comment_u_name = 'System'
  comment_initials = 'S'
  if comment.user.respond_to?(:id, :name)
    comment_u_id = comment.user.id
    comment_u_name = comment.user.name
    comment_initials = comment.user.name.split(' ').first[0] + ((comment.user.name.split(' ')[1][0] rescue nil) or comment.user.name.split(' ').first[1])
  end
  json.comment_user_id comment_u_id
  json.comment_user_name comment_u_name
  json.comment_user_initial comment_initials
end

expenses_sorted_by = params[:expenses_sorted_by] || 'category'
json.expenses_sorted_by expenses_sorted_by
if expenses_sorted_by == 'category'
  sorted_expenses = @result.expenses_category_sorted
elsif expenses_sorted_by == 'date'
  sorted_expenses = @result.expenses_date_sorted
else
  sorted_expenses = @result.expenses_category_sorted
end

json.expense_sections sorted_expenses do |category|
  json.extract! category, :section_name, :section_total

  json.expenses category[:expenses] do |expense|
    json.extract! expense, :id, :merchant_name, :amount_value, :expense_type_id, :category_name,
                           :distance_value, :distance_rate_value, :time_value, :time_rate_value
    if expense.note
      if expense.note.length < 29
        json.note expense.note
      else
        json.note expense.note[0..29] + '...'
      end
    end
    # json.extract! expense, :id, :note
    json.date expense.date.strftime('%d %b %y')
    json.reimbursable expense.reimbursable
    json.violations do
      items = @result.violations[expense.id]
      json.blocking_present (items[:expense_blocking].present? or items[:budget_blocking].present? or items['expense_blocking'].present? or items['budget_blocking'].present?)
      json.warning_present (items[:expense_warning].present? or items[:budget_warning].present? or items['expense_warning'].present? or items['budget_warning'].present?)
      json.items items
    end
    if expense.distance_expense?
      json.locations expense.distance_expense.locations, :name, :address, :latitude, :longitude, :order, :maps_id
    end
    json.potential_duplicate expense.has_duplicate_expenses?
  end
end

json.receipts @result.expenses do |expense|
  unless expense.receipts.blank? or expense.receipts.first.image.url == '/assets/original/missing.png'
    json.id expense.receipts.first.id
    json.hard_copy_received expense.receipts.first.hard_copy_received
    json.image do
      json.file_type expense.receipts.first.file_format
      json.original expense.receipts.first.image.url
      json.thumb expense.receipts.first.image.url(:thumb)
    end
    # json.url expense.receipts.first.image.url
    # json.file_type expense.receipts.first.file_format
    json.date expense.date.strftime('%d %b %Y')
    json.merchant_name expense.merchant_name
    json.amount_value expense.amount_value
  end
end

json.actions do
  json.dummy 'dummy'
  @result.actions.each do |key, value|
    json.set! key, (value[:url] or value[:value])
  end
end

json.violations do
  json.blocking_present @result.has_blocking?
  json.warning_present @result.has_warning?
  json.blocking_messages @result.blocking_array
  json.warning_messages @result.warning_array
end

json.custom_fields do
  json.array! @result.report.custom_fields
end