namespace :tracker_task do
  desc 'TODO'
  task run: :environment do
    TrackerListener.run
  end

end
