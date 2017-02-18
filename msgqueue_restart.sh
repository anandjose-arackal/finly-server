kill -TERM $(cat $HOME/app/shared/tmp/pids/transaction_queue.pid)
RAILS_ENV=production nohup rails runner TransactionsMsgQueuePoller.run > $HOME/app/shared/log/transactions_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/transaction_queue.pid

kill -TERM $(cat $HOME/app/shared/tmp/pids/balance_queue.pid)
RAILS_ENV=production nohup rails runner BalanceMsgQueuePoller.run > $HOME/app/shared/log/balance_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/balance_queue.pid
