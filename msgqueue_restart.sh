#!/usr/bin/env bash

restart_process()
{
ENV=$1
PID_FILE=$HOME/app/shared/tmp/pids/$2
RUNNER=$3
LOG_FILE=$HOME/app/shared/log/$4

# Check if the pid file exists
if [ -f $PID_FILE ]
then
    # Check if the process exists
    if  ps -p $(cat $PID_FILE) > /dev/null
    then
        # Kill process
        kill -TERM $(cat $PID_FILE)
     fi
fi
cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV="$ENV" ; nohup $HOME/.rbenv/bin/rbenv exec rails runner $RUNNER >> $LOG_FILE 2>&1 & echo $! > $PID_FILE )
}

ENV=$1
if [ -z "$ENV" ]
then
    ENV=production
    echo "MsgQueueRestartScript: Environment not passed. Restarting queue in Production Environment"
fi
restart_process $ENV transaction_queue.pid TransactionsMsgQueuePoller.run transactions_msg_queue_poller.log
restart_process $ENV balance_queue.pid BalanceMsgQueuePoller.run balance_msg_queue_poller.log

## Check if the pid file exists
#if [ -f $HOME/app/shared/tmp/pids/transaction_queue.pid ]
#then
#    # Check if the process exists
#    if  ps -p $(cat $HOME/app/shared/tmp/pids/transaction_queue.pid) > /dev/null
#    then
#        # Kill process
#        kill -TERM $(cat $HOME/app/shared/tmp/pids/transaction_queue.pid)
#     fi
#fi
#cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV=local_vm ; nohup $HOME/.rbenv/bin/rbenv exec rails runner TransactionsMsgQueuePoller.run >> $HOME/app/shared/log/transactions_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/transaction_queue.pid )
#
## Check if the pid file exists
#if [ -f $HOME/app/shared/tmp/pids/balance_queue.pid ]
#then
#    # Check if the process exists
#    if  ps -p $(cat $HOME/app/shared/tmp/pids/balance_queue.pid) > /dev/null
#    then
#        # Kill process
#        kill -TERM $(cat $HOME/app/shared/tmp/pids/balance_queue.pid)
#     fi
#fi
#cd $HOME/app/current && ( export RBENV_ROOT="$HOME/.rbenv" RBENV_VERSION="2.3.1" RACK_ENV=local_vm ; nohup $HOME/.rbenv/bin/rbenv exec rails runner BalanceMsgQueuePoller.run >> $HOME/app/shared/log/balance_msg_queue_poller.log 2>&1 & echo $! > $HOME/app/shared/tmp/pids/balance_queue.pid )

#ssh -t viveka@finly.io -p2212 ssh viveka@192.168.5.12 'sh app/shared/msgqueue_restart.sh'