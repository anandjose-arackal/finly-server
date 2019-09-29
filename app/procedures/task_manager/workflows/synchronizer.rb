# This class is used for running all database workflows
class TaskManager::Workflows::Synchronizer < TaskManager::API

  def self.sync_with_database(model, event, &block)
    Events::Synchronizer.for(:database).register(model, "#{model.event_channel}.#{event}", &block)
  end

  Documents::Master.list.each do |document_name|
    model = Documents::Master.for(document_name)
    record_events = model.record_events
    collection_events = model.collection_events

    all_events = record_events + collection_events
    all_events.each do |event|
      sync_with_database TaskWorkflow, event do |record, user, message|
        # TaskManager::Workflows::Synchronizer.new(record, user, message).run
        TaskManager::Runner::BackgroundJob.perform_async(
            {
                task_workflow_id: record.id,
                message: message,
                current_user: user,
                trigger: :event
            }
        )
      end
    end
  end

end