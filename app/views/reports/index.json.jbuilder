json.array!(@result.paginated_reports) do |report|
  json.extract! report, :id, :name
  json.user do
    json.extract! report.user, :name
  end
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
  json.status @result.status_name(report)
  json.total(('%.2f' % report.total_amount))
  json.currency_id report.base_currency_id
  json.date report.created_at.strftime("%d %b")
end