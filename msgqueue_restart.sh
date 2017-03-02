#!/usr/bin/env bash
if [ -f $HOME/app/shared/tmp/pids/transaction_queue.pid ] && [ ps -p $HOME/app/shared/tmp/pids/transaction_queue.pid > /dev/null ]
then
    kill -TERM $(cat $HOME/app/shared/tmp/pids/transaction_queue.pid)
fi
cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV="production" ; nohup $HOME/.rbenv/bin/rbenv exec rails runner TransactionsMsgQueuePoller.run > $HOME/app/shared/log/transactions_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/transaction_queue.pid )

if [ -f $HOME/app/shared/tmp/pids/balance_queue.pid ] && [ ps -p $HOME/app/shared/tmp/pids/balance_queue.pid > /dev/null ]
then
    kill -TERM $(cat $HOME/app/shared/tmp/pids/balance_queue.pid)
fi
cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV="production" ; nohup $HOME/.rbenv/bin/rbenv exec rails runner BalanceMsgQueuePoller.run > $HOME/app/shared/log/balance_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/balance_queue.pid )