namespace :monit do

  desc 'Start monit monitoring'
  task :monitor do
    on roles :all do
      execute('sudo /bin/monit monitor all')
    end
  end

  desc 'Stop monit monitoring'
  task :unmonitor do
    on roles :all do
      execute('sudo /bin/monit unmonitor all')
    end
  end

end

# before 'deploy', 'monit:unmonitor'
# after 'deploy', 'monit:monitor'
# after 'deploy:failed', 'monit:monitor'