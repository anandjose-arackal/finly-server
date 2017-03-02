#!/usr/bin/env bash
# Check if the pid file exists
#if [ -f $HOME/app/shared/tmp/pids/balance_queue.pid ]
#then
#    # Check if the process exists
#    if  ps -p $(cat $HOME/app/shared/tmp/pids/balance_queue.pid) > /dev/null
#    then
#        # Kill process
#        kill -TERM $(cat $HOME/app/shared/tmp/pids/balance_queue.pid)
#     fi
#fi
cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV="production" ; nohup $HOME/.rbenv/bin/rbenv exec rails runner BalanceMsgQueuePoller.run >> $HOME/app/shared/log/balance_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/balance_queue.pid )