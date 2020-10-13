# config valid only for current version of Capistrano
lock '~> 3.11'

if ['api_production',
    'background_production', 'background_production_bgp', 'yes_bank_balance_poller',
    'console_production'].include?(fetch(:stage)&.to_s)
  load_secure_storage(:production)
elsif ['background_production_console'].include?(fetch(:stage)&.to_s)
  load_secure_storage(:background_production_console)
end

set :application, 'finly-server'

set :repo_url, 'git@gitlab.com:finlycore/finly-server.git'

set :branch, ENV['REFERENCE'] || ENV['BRANCH'] || :master

case fetch(:stage)
when :aws_production, :background_production, :foreground_production, :console_production,
    :api_production, :background_production_bgg, :background_production_bgp, :background_production_bgpc, :background_production_console
  branch = fetch :branch
  unless ['master', :master].include?(branch)
    raise 'This branch cannot be deploy to production. Please select the correct branch'
  end
  set :deploy_to, '/home/ubuntu/app'
  set :rails_env, 'production'
when :yes_bank_balance_poller
  branch = fetch :branch
  unless ['master', :master].include?(branch)
    raise 'This branch cannot be deploy to production. Please select the correct branch'
  end
  set :deploy_to, '/home/ubuntu/app_yb_balance'
  set :rails_env, 'production'
when :staging, :development
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
when :development_6
  set :deploy_to, '/home/centos/app_6'
  set :rails_env, 'staging'
when :development_7
  set :deploy_to, '/home/centos/app_7'
  set :rails_env, 'staging'
when :development_8
  set :deploy_to, '/home/centos/app_8'
  set :rails_env, 'staging'
when :uat
  set :deploy_to, '/home/centos/app'
  set :rails_env, 'uat'
when :uat_2, :bbps
  set :deploy_to, '/home/centos/app_2'
  set :rails_env, 'uat'
when :pre_uat
  set :deploy_to, '/home/centos/app'
  set :rails_env, 'staging'
when :pre_uat2
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
  config/gstin_verification_config.yml
  config/redis_config.yml
  config/mattermost_config.yml
  config/integrations.yml
  config/insights_config.yml
  config/bbps_config.yml
  config/sidekiq.yml
  config/hutch.yml
  config/web_client.yml
  config/azure_config.yml
  config/finly_macros.yml
  config/finly_collect.yml
  config/feature_flipper.yml
  config/posthog.yml
}
case fetch(:stage)
when :itzcash_production, :aws_production, :background_production, :foreground_production, :console_production, :api_production, :background_production_console,
    :background_production_bgg, :background_production_bgp, :background_production_bgpc
  linked_files << 'config/elastic_apm.yml'
  linked_files << 'config/bunny.yml'
  linked_files << 'config/master_users.yml'
  # linked_files << "config/sentry.yml"
when :yes_bank_balance_poller
  linked_files << "config/sidekiq_yes_bank_balance_poller.yml"
  linked_files << "config/elastic_apm.yml"
  linked_files << 'config/bunny.yml'
end
set :linked_files, linked_files
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads node_modules client/node_modules}
set :keep_releases, 5
set :nvm_type, :user # or :system, depends on your nvm setup
set :nvm_node, 'v12.18.3'
set :nvm_map_bins, %w{node npm yarn}

set :yarn_target_path, -> { release_path.join('client') } #
set :yarn_flags, '--production --silent --no-progress'    # default
set :yarn_roles, :all                                     # default
set :yarn_env_variables, {}

# set :rails_env, "staging"
# set :rails_env, 'production'
# set :rvm_type, :user
# set :rvm_ruby_version, 'ruby-2.3.1' # Edit this if you are using MRI Ruby

# set :default_env, { rvm_bin_path: '~/.rvm/bin' }

# setting up rollbar environment variables for deploy tracking
set :rollbar_token, 'ca504254626b4bf69eb1a1ec0b3aea23'
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

set :sentry_host, 'https://sentry.finly.io/' # https://sentry.io by default
set :sentry_api_token, 'bed720c1d80849fcbc96fba0485460e6'
set :sentry_organization, 'finly' # fetch(:application) by default
set :sentry_project, 'finly-server'     # fetch(:application) by default
set :sentry_repo, 'finlycore/finly-server' # computed from repo_url by default

before 'deploy:starting', 'sentry:validate_config'
after 'deploy:published', 'sentry:notice_deployment'

set :puma_rackup, -> { File.join(current_path, 'config.ru') }
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
set :ssh_options, :keepalive => true
set :puma_user, fetch(:user)
set :sidekiq_user, fetch(:user)

# Since we do not run monit on all instances, we skip default_hooks so it can be manually set in required env
set :sidekiq_monit_default_hooks, false

set :whenever_roles, ["whenever_cron"]

set :slackistrano, {
    channel: '#general',
    team: 'finlyteam',
    token: 'xoxb-69742039698-481828577170-pL7adrfoCVs74cggPFKiRNhj',
    slack_via_slackbot: true
}

before "deploy:assets:precompile", "deploy:yarn_install"

namespace :deploy do
  desc 'Run rake yarn:install'
  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end
end
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
