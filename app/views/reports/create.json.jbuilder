json.extract! @report, :id, :name, :memo, :status_name, :memo
json.user_name @report.user.name
json.user_initial @report.user.name.split(' ').first[0] + ((@report.user.name.split(' ')[1][0] rescue nil) || @report.user.name.split(' ').first[1])


if @report.policy
  json.policy @report.policy.name
end

json.status "success"
rds = ReportDetailService.new(@report)
json.total rds.total_amount
json.date @report.created_at.strftime("%d %b")