json.array!(@index_presenter.reports) do |report|
  json.extract! report, :id, :name, :memo, :status, :status_name, :memo
  if report.policy
    json.policy report.policy.name
  end
  json.status report.status.name
  json.total report.total_amount
  json.date report.created_at.strftime("%d %b")
end