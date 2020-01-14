class Insights::Index < Transactions::API

  step Transactions::Resolver::Model(InsightDashboard)

end