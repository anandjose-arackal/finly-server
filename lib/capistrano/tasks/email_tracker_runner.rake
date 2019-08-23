def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :email_tracker_pid, -> {File.join(shared_path, 'tmp', 'pids', 'email_tracker_queue.pid')}
    set :email_tracker_log, -> {File.join(shared_path, 'log', 'email_tracker.log')}
    set :email_tracker_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :email_tracker_runner, -> {'EmailNotificationPoller.run'}
    set :email_tracker_role, -> {:app}
    set :email_tracker_env, fetch(:rack_env, fetch(:rails_env, 'production'))
  end
end

namespace :email_tracker do
  desc 'Start Email Tracker'
  task :start do
    on roles fetch(:email_tracker_role) do
      pid_file = fetch(:email_tracker_pid)
      args = "#{fetch(:email_tracker_runner)} >> #{fetch(:email_tracker_log)} 2>&1 & echo $! > #{fetch(:email_tracker_pid)}"
      within release_path do
        with rack_env: fetch(:email_tracker_env) do
          execute(:rails, :runner, args) unless process_exists?(pid_file)
        end
      end
    end
  end

  desc 'Stop Email Tracker'
  task :stop do
    on roles fetch(:email_tracker_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:email_tracker_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Email Tracker'
  task :restart do
    invoke 'email_tracker:stop'
    invoke 'email_tracker:start'
  end
end

after 'deploy:updated', 'email_tracker:stop'
after 'deploy:reverted', 'email_tracker:stop'
after 'deploy:published', 'email_tracker:start'