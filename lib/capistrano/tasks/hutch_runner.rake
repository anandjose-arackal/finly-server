def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :hutch_pid, -> {File.join(shared_path, 'tmp', 'pids', 'hutch.pid')}
    set :hutch_log, -> {File.join(shared_path, 'log', 'hutch.log')}
    # set :hutch_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :hutch_role, -> {:hutch}
    set :hutch_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :hutch_env, -> {fetch(:rack_env, fetch(:rails_env, 'production'))}
  end
end

namespace :hutch do
  desc 'Start hutch'
  task :start do
    on roles fetch(:hutch_role) do
      within release_path do
        args = "#{fetch(:hutch_runner)} >> #{fetch(:hutch_log)} 2>&1 & echo $! > #{fetch(:hutch_pid)}"
        with rails_env: fetch(:hutch_env) do
          execute(:bundle, :exec, :hutch, args) unless process_exists?(fetch(:hutch_pid))
        end
      end
    end
  end

  desc 'Stop hutch'
  task :stop do
    on roles fetch(:hutch_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:hutch_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart hutch'
  task :restart do
    invoke 'hutch:stop'
    invoke 'hutch:start'
  end
end

after 'deploy:updated', 'hutch:stop'
after 'deploy:reverted', 'hutch:stop'
after 'deploy:published', 'hutch:start'