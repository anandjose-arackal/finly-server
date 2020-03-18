class Insights::Index < Transactions::API

  step Resolver::Transactions::Load(model: InsightDashboard)

end