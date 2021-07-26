class ImportJobs::Resolver < Resolver::API

  entity ImportJob

  def load(params)
    user.import_jobs.order(created_at: :desc)
  end

end