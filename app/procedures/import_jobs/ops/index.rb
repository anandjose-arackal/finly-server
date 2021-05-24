class ImportJobs::Ops::Index < Transactions::API
  step Policy::Pundit(ImportJobs::Policy, :index?)
  step Resolver::Transactions::Load(klass: ImportJobs::Resolver, paginate: true)
end
