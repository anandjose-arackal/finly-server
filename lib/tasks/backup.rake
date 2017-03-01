namespace :backup do
  desc 'Perform backup operation'
  task :execute do
    sh "/bin/bash -l -c '/home/vivek/.rbenv/shims/backup perform -t production_backup'"
  end
end
