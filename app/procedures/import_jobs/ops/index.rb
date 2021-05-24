class ImportJobs::Ops::Index < Transaction
  step Policy::Pundit(ImportJobs::Policy, :index?)
  step Resolver::Transactions::Load(klass: ImportJobs::Resolver, paginate: true)
end
