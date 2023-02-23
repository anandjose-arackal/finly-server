def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :transaction_poller_pid, -> { File.join(shared_path, 'tmp', 'pids', 'transaction_queue.pid') }
    set :transaction_poller_log, -> { File.join(shared_path, 'log', 'transactions_msg_queue_poller.log') }
    set :transaction_poller_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :transaction_poller_runner, -> { 'TransactionsMsgQueuePoller.run' }
    set :transaction_poller_role, -> { :app }
    set :transaction_poller_env, fetch(:rack_env, fetch(:rails_env, 'production'))
  end
end

namespace :transaction_poller do
  desc "Start Transaction Poller"
  task :start do
    on roles fetch(:transaction_poller_role) do
      pid_file = fetch(:transaction_poller_pid)
      args = "#{fetch(:transaction_poller_runner)} >> #{fetch(:transaction_poller_log)} 2>&1 & echo $! > #{fetch(:transaction_poller_pid)}"
      within release_path do
        with rack_env: fetch(:transaction_poller_env) do
          execute(:rails, :runner, args) unless process_exists?(pid_file)
          # run "nohup $HOME/.rbenv/bin/rbenv exec rails runner #{args}" unless process_exists?(pid_file)
        end
      end
    end
  end

  desc "Stop Transaction Poller"
  task :stop do
    on roles fetch(:transaction_poller_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:transaction_poller_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Transaction Poller'
  task :restart do
    invoke 'transaction_poller:stop'
    invoke 'transaction_poller:start'
  end
end

# expense card discontinued, transaction_poller meant to fetch ATM transaction from ebix finly middle man server
#after 'deploy:updated', 'transaction_poller:stop'
#after 'deploy:reverted', 'transaction_poller:stop'
#after 'deploy:published', 'transaction_poller:start'