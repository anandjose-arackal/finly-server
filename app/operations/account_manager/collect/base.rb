class AccountManager::Collect::Base < BackgroundOperation
  queue_as :payments_queue


end