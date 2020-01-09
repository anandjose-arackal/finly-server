# require 'clockwork'
# require 'clockwork/database_events'
# require_relative "../../config/boot"
# require_relative "../../config/environment"
#
# module Clockwork
#   # TaskManager::Workflows::Triggers::Scheduler.tasks.each do |task|
#   #   task.setup_job(self)
#   # end
#
#   Clockwork.manager = DatabaseEvents::Manager.new
#   sync_database_events model: TaskSchedule, every: 1.minute do |model_instance|
#
#   end
# end