def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :usage_tracker_pid, -> {File.join(shared_path, 'tmp', 'pids', 'usage_tracker_queue.pid')}
    set :usage_tracker_log, -> {File.join(shared_path, 'log', 'usage_tracker.log')}
    set :usage_tracker_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :usage_tracker_runner, -> {'TrackerListener.run'}
    set :usage_tracker_role, -> {:app}
    set :usage_tracker_env, fetch(:rack_env, fetch(:rails_env, 'production'))
  end
end

namespace :usage_tracker do
  desc 'Start Usage Tracker'
  task :start do
    on roles fetch(:usage_tracker_role) do
      pid_file = fetch(:usage_tracker_pid)
      args = "#{fetch(:usage_tracker_runner)} >> #{fetch(:usage_tracker_log)} 2>&1 & echo $! > #{fetch(:usage_tracker_pid)}"
      within release_path do
        with rack_env: fetch(:usage_tracker_env) do
          execute(:rails, :runner, args) unless process_exists?(pid_file)
        end
      end
    end
  end

  desc 'Stop Usage Tracker'
  task :stop do
    on roles fetch(:usage_tracker_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:usage_tracker_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Usage Tracker'
  task :restart do
    invoke 'usage_tracker:stop'
    invoke 'usage_tracker:start'
  end
end

after 'deploy:updated', 'usage_tracker:stop'
after 'deploy:reverted', 'usage_tracker:stop'
after 'deploy:published', 'usage_tracker:start'