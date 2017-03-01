namespace :backup do
  desc 'Perform backup operation'
  task :execute => :environment do
    sh 'backup perform -t production_backup'
  end
end