class BulkApproveWorker
  include Sidekiq::Worker

  def perform(user_id, params)
    user = User.find(user_id)
    params['async'] = true
    ::Reports::BulkApprove.(user, params)
  end
end
