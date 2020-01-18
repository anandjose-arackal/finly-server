class Insights::Index < Transactions::API

  step Transactions::Resolver::Load(model: InsightDashboard)

end