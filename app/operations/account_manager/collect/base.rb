class AccountManager::Collect::Base < BackgroundOperation
  sidekiq_options queue: :payments_queue

end