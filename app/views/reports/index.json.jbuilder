json.array!(@reports) do |report|
  json.extract! report, :id, :name, :memo, :status, :status_name, :memo
  if report.policy
    json.policy report.policy.name
  end
  json.status report.status.name
  rds = ReportDetailService.new(report)
  json.total rds.total_amount
  json.date report.created_at.strftime("%d %b")
end