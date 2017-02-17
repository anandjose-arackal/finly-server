sidekiq: RAILS_ENV=production bundle exec sidekiq -d -L log/sidekiq.log
crono: RAILS_ENV=production bundle exec crono start
transactions_queue: RAILS_ENV=production nohup rails runner TransactionsMsgQueuePoller.run > log/transactions_msg_queue_poller.log &
balance_queue: RAILS_ENV=production nohup rails runner BalanceMsgQueuePoller.run > log/balance_msg_queue_poller.log &
