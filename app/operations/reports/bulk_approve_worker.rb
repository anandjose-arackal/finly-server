class BulkApproveWorker
  include Sidekiq::Worker

  def perform(user_id, params)
    user = User.find(user_id)
    Reports::BulkApprove(user, params)
  end
end
