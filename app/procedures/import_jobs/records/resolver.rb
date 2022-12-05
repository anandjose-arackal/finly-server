class ImportJobs::Records::Resolver < Resolver::API

  entity ImportRecord

  def load(params)
    user.import_jobs.find_by(uuid: params["id"])&.records.order(created_at: :asc)
  end

end