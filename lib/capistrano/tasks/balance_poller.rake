def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :balance_poller_pid, -> { File.join(shared_path, 'tmp', 'pids', 'balance_queue.pid') }
    set :balance_poller_log, -> { File.join(shared_path, 'log', 'balance_msg_queue_poller.log') }
    set :balance_poller_env, -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :balance_poller_runner, -> { 'BalanceMsgQueuePoller.run' }
    set :balance_poller_role, -> { :app }
    set :balance_poller_env, fetch(:rack_env, fetch(:rails_env, 'production'))
  end
end

namespace :balance_poller do
  desc "Start Balance Poller"
  task :start do
    on roles fetch(:balance_poller_role) do
      pid_file = fetch(:balance_poller_pid)
      args = "#{fetch(:balance_poller_runner)} >> #{fetch(:balance_poller_log)} 2>&1 & echo $! > #{fetch(:balance_poller_pid)}"
      within release_path do
        with rack_env: fetch(:balance_poller_env) do
          execute(:rails, :runner, args) unless process_exists?(pid_file)
        end
      end
    end
  end

  desc "Stop Balance Poller"
  task :stop do
    on roles fetch(:balance_poller_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:balance_poller_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Balance Poller'
  task :restart do
    invoke 'balance_poller:stop'
    invoke 'balance_poller:start'
  end
end

after 'deploy:updated', 'balance_poller:stop'
after 'deploy:reverted', 'balance_poller:stop'
after 'deploy:published', 'balance_poller:start'