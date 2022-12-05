class ImportJobs::Ops::Show < Transactions::API
  step Model(ImportJob, :find_by_uuid)
end