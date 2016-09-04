json.extract! @show_presenter.report, :id, :name, :memo, :status_name, :memo, :report_status_id
json.user_name @show_presenter.report.user.name
json.user_initial @show_presenter.report.user.name.split(' ').first[0] + (@show_presenter.report.user.name.split(' ')[1][0] || @show_presenter.report.user.name.split(' ').first[1])
json.status @show_presenter.status
json.manager_name @show_presenter.manager.name
json.export_csv export_report_path(report_id: @show_presenter.report.id, view: params[:view],:format => :csv)
json.export_xls export_report_path(report_id: @show_presenter.report.id, view: params[:view],:format => :xls)
json.export_pdf export_report_path(report_id: @show_presenter.report.id, view: params[:view],:format => :pdf)

if @show_presenter.report.policy
  json.policy @show_presenter.report.policy.name
end

json.policies @show_presenter.report.user.policies do |policy|
  json.extract! policy, :id, :name
end

json.status @show_presenter.report.status.name
json.total @show_presenter.report.total_amount
json.date @show_presenter.report.created_at.strftime("%d %b")

json.comments @show_presenter.comments do |comment|
  json.content comment.generate
  json.created_at comment.created_at.strftime("%d %b %y")
  if comment.user.respond_to?(:id, :name)
    json.comment_user_id comment.user.id
    json.comment_user_name comment.user.name
    json.comment_user_initial comment.user.name.split(' ').first[0] + (comment.user.name.split(' ')[1][0] || comment.user.name.split(' ').first[1])
  end
end

json.expense_sections @show_presenter.expenses_category_sorted do |category|
  json.extract! category, :section_name, :section_total

  json.expenses category[:expenses] do |expense|
    json.extract! expense, :id, :note, :merchant_name, :amount_value
    # json.extract! expense, :id, :note
    json.date expense.date.strftime("%d %b %y")
  end
end


@show_presenter.expenses_category_sorted.each do |category|
  json.receipts category[:expenses] do |expense|
    unless(expense.receipts.blank? or expense.receipts.first.image.url == "/assets/original/missing.png")
      json.url expense.receipts.first.image.url
      json.date expense.date.strftime("%d %b %y")
      json.merchant_name expense.merchant_name
      json.amount_value expense.amount.precision_value
    end

  end
end

