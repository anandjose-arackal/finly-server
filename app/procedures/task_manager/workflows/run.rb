class TaskManager::Workflows::Run < Transactions::API

  schema do
    params do
      required(:event_workflow).filled
    end
  end



end