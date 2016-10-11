json.array!(@result.paginated_reports) do |report|
  json.extract! report, :id, :name, :status, :status_name
  if report.memo
    if report.memo[21]
      json.memo report.memo[0, 20] + "..."
    else
      json.memo report.memo
    end
  end
  if report.policy
    json.policy report.policy.name
  end
  json.status report.status.name
  json.total(('%.2f' % report.total_amount))
  json.date report.created_at.strftime("%d %b")
end