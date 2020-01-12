def pid_file_exists?(pid_file)
  test(*("[ -f #{pid_file} ]").split(' '))
end

def process_exists?(pid_file)
  pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
end

namespace :load do
  task :defaults do
    set :sneakers_pid, -> {File.join(shared_path, 'tmp', 'pids', 'sneakers.pid')}
    set :sneakers_log, -> {File.join(shared_path, 'log', 'sneakers.log')}
    set :sneakers_env, -> {fetch(:rack_env, fetch(:rails_env, fetch(:stage)))}
    set :sneakers_role, -> {:sneakers}
    set :sneakers_env, fetch(:rack_env, fetch(:rails_env, 'production'))
  end
end

namespace :sneakers do
  desc 'Start Sneakers'
  task :start do
    on roles fetch(:sneakers_role) do
      pid_file = fetch(:sneakers_pid)
      within release_path do
        with rack_env: fetch(:sneakers_env) do
          execute('rake sneakers:run') unless process_exists?(pid_file)
        end
      end
    end
  end

  desc 'Stop Sneakers'
  task :stop do
    on roles fetch(:sneakers_role) do
      if test("[ -d #{release_path} ]")
        pid_file = fetch(:sneakers_pid)
        execute("kill -TERM `cat #{pid_file}`") if process_exists?(pid_file)
      end
    end
  end

  desc 'Restart Sneakers'
  task :restart do
    invoke 'sneakers:stop'
    invoke 'sneakers:start'
  end
end

after 'deploy:updated', 'sneakers:stop'
after 'deploy:reverted', 'sneakers:stop'
after 'deploy:published', 'sneakers:start'