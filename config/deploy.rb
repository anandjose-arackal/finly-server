# config valid only for current version of Capistrano
lock '3.11.0'

if ['aws_production', 'background_production'].include?(fetch(:stage)&.to_s)
  load_secure_storage(:production)
end

set :application, 'finly-server'

set :repo_url, 'git@gitlab.com:finlycore/finly-server.git'

set :branch, ENV['BRANCH'] || :master

  case fetch(:stage)
  when :itzcash_production
    raise 'Cannot deploy this to itzcash. Deploy it to AWS instead'
  # branch = fetch :branch
  # unless ['staging', :staging].include?(branch)
  #   raise 'This branch cannot be deploy to production. Please select the correct branch'
  # end
  # set :deploy_to, '/home/viveka/app'
  # set :rails_env, 'production'
  # todo - configure this for production once everything is set up
  when :aws_production, :background_production
    branch = fetch :branch
    unless ['master', :master].include?(branch)
      raise 'This branch cannot be deploy to production. Please select the correct branch'
    end
    set :deploy_to, '/home/centos/app'
    set :rails_env, 'production'
  when :itzcash
    set :deploy_to, '/usr/local/app'
    set :rails_env, 'itzcash_uat'
  when :staging, :development, :combined_development, :insights, :demo_2, :shapoorji, :olx, :migrated_test
    set :deploy_to, '/home/centos/app'
    set :rails_env, 'staging'
  when :development_2
    set :deploy_to, '/home/centos/app_2'
    set :rails_env, 'staging'
  when :development_3
    set :deploy_to, '/home/centos/app_3'
    set :rails_env, 'staging'
  when :development_4
    set :deploy_to, '/home/centos/app_4'
    set :rails_env, 'staging'
  when :development_5
    set :deploy_to, '/home/centos/app_5'
    set :rails_env, 'staging'
  when :original_test
    set :deploy_to, '/home/centos/app_2'
    set :rails_env, 'staging'
  when :migrated_script_testing
    set :deploy_to, '/home/centos/app_3'
    set :rails_env, 'staging'
end

set :pty, false
linked_files = %w{
  config/database.yml
  config/application.yml
  config/data/bypass_authorized_users.yml
  config/mailer_config.yml
  config/aws_config.yml
  config/yes_bank_config.yml
}
case fetch(:stage)
when :itzcash_production, :aws_production, :background_production
  linked_files << 'config/sidekiq.yml'
  linked_files << 'config/elastic_apm.yml'
  # linked_files << "config/sentry.yml"
end
set :linked_files, linked_files
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5


# set :rails_env, "staging"
# set :rails_env, 'production'
# set :rvm_type, :user
# set :rvm_ruby_version, 'ruby-2.3.1' # Edit this if you are using MRI Ruby

# set :default_env, { rvm_bin_path: '~/.rvm/bin' }

# setting up rollbar environment variables for deploy tracking
set :rollbar_token, 'ca504254626b4bf69eb1a1ec0b3aea23'
set :rollbar_env, Proc.new {fetch :stage}
set :rollbar_role, Proc.new {:app}

set :puma_rackup, -> {File.join(current_path, 'config.ru')}
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock" #accept array for multi-bind
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_access_log, "#{shared_path}/log/puma_error.log"
set :puma_error_log, "#{shared_path}/log/puma_access.log"
set :puma_role, :app
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_threads, [0, 24]
set :puma_workers, 0
set :puma_worker_timeout, nil
set :puma_init_active_record, true
set :puma_preload_app, false


set :slackistrano, {
    channel: '#general',
    team: 'finlyteam',
    token: 'xoxb-69742039698-481828577170-pL7adrfoCVs74cggPFKiRNhj',
    slack_via_slackbot: true
}

# before 'disable_secure_storage', 'runner:restart'
#
# # Restart runner
# namespace :runner do
#   task :restart do
#     on roles(:app) do
#       within release_path do
#         env = fetch(:rails_env)
#         case env
#           when :staging, 'production'
#             execute('sh', 'msgqueue_restart.sh', fetch(:rails_env))
# `ssh -t viveka@finly.io -p2212 ssh viveka@192.168.5.12 'sh app/current/msgqueue_restart.sh #{fetch(:rails_env)}'`
#         end
#         # execute("sh app/shared/msgqueue_restart.sh production")
#       end
#     end
#   end
# end


#
# Example: cap staging rake:invoke task=rebuild_table_abc
# namespace :rake do
#   desc 'Run a task on a remote server'
#   # run like: cap staging rake:invoke task=a_certain_task
#   task :invoke do
#     # run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")
#    end
# end

# after 'deploy', 'deploy:card_restrictions_association_fix'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
