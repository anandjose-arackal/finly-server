# This class is used for running all database workflows
class TaskManager::Workflows::Synchronizer < TaskManager::API

  # Documents::Master.list.each do |document_name|
  #   model = Documents::Master.for(document_name)
  #   record_events = model&.record_events || []
  #   collection_events = model&.collection_events || []
  #
  #   all_events = record_events + collection_events
  #   all_events.each do |event|
  #     Events::Synchronizer.for(:database).sync(
  #         TaskWorkflow,
  #         event,
  #         name: "Generic Handler",
  #         consumer_key: 'workflow.generic.handler') do |record, user, message|
  #       TaskManager::Runner::BackgroundJob.perform_async(
  #           {
  #               task_workflow_id: record.id,
  #               message: message,
  #               current_user: user,
  #               trigger: :event
  #           }
  #       )
  #     end
  #   end
  # end

end