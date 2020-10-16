def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :status_index_monitor_pid, -> {File.join(shared_path, 'tmp', 'pids', 'status_index_monitor_queue.pid')}
    set :status_index_monitor_log, -> {File.join(shared_path, 'log', 'status_index_monitor.log')}
    set :status_index_monitor_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :status_index_monitor_runner, -> {'SearchIndex::Services::UpdateMonitor.run'}
    set :status_index_monitor_role, -> {:app}
    set :status_index_monitor_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :status_index_monitor_env, -> {fetch(:rack_env, fetch(:rails_env, 'production'))}
  end
end

namespace :status_index_monitor do
  desc 'Start Search Index Monitor'
  task :start do
    on roles fetch(:status_index_monitor_role) do
      pid_file = fetch(:status_index_monitor_pid)
      args = "#{fetch(:status_index_monitor_runner)} >> #{fetch(:status_index_monitor_log)} 2>&1 & echo $! > #{fetch(:status_index_monitor_pid)}"
      within release_path do
        with rack_env: fetch(:status_index_monitor_env) do
          execute(:rails, :runner, args) unless process_exists?(pid_file)
        end
      end
    end
  end

  desc 'Stop Search Index Monitor'
  task :stop do
    on roles fetch(:status_index_monitor_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:status_index_monitor_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Email Tracker'
  task :restart do
    invoke 'status_index_monitor:stop'
    invoke 'status_index_monitor:start'
  end
end

after 'deploy:updated', 'status_index_monitor:stop'
after 'deploy:reverted', 'status_index_monitor:stop'
after 'deploy:published', 'status_index_monitor:start'