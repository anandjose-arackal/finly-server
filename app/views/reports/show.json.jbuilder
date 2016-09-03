json.extract! @report, :id, :name, :memo, :status_name, :memo, :report_status_id
json.user_name @report.user.name
json.user_initial @report.user.name.split(' ').first[0] + (@report.user.name.split(' ')[1][0] || @report.user.name.split(' ').first[1])
json.status @status
json.manager_name @manager_name
json.export_csv export_report_path(report_id: @report.id, view: params[:view],:format => :csv)
json.export_xls export_report_path(report_id: @report.id, view: params[:view],:format => :xls)
json.export_pdf export_report_path(report_id: @report.id, view: params[:view],:format => :pdf)

if @report.policy
  json.policy @report.policy.name
end

json.policies @report.user.policies do |policy|
  json.extract! policy, :id, :name
end

json.status @report.status.name
rds = ReportDetailService.new(@report)
json.total rds.total_amount
json.date @report.created_at.strftime("%d %b")

json.comments @comments do |comment|
  json.content comment.content
  json.created_at comment.created_at.strftime("%d %b %y")
  if comment.user.respond_to?(:id, :name)
    json.comment_user_id comment.user.id
    json.comment_user_name comment.user.name
    json.comment_user_initial comment.user.name.split(' ').first[0] + (comment.user.name.split(' ')[1][0] || comment.user.name.split(' ').first[1])
  end
end

json.expense_sections @expenses do |category|
  json.extract! category, :section_name, :section_total

  json.expenses category[:expenses] do |expense|
    # json.extract! expense, :id, :note, :merchant_name, :amount_value
    json.extract! expense, :id, :note
    json.date expense.date.strftime("%d %b %y")
  end
end


@expenses.each do |category|
  json.receipts category[:expenses] do |expense|
    unless(expense.receipts.blank? or expense.receipts.first.image.url == "/assets/original/missing.png")
      json.url expense.receipts.first.image.url
      json.date expense.date.strftime("%d %b %y")
      json.merchant_name expense.merchant_name
      json.amount_value expense.amount.precision_value
    end

  end
end

