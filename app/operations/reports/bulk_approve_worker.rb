class BulkApproveWorker
  include Sidekiq::Worker

  def perform(user, params)
    params = JSON.load(params)
    Reports::BulkApprove(user, params)
  end
end
