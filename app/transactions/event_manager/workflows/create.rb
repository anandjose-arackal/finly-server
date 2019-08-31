class EventManager::Workflows::Create < Transactions::API

  step Model(EventWorkflow, :new)
  step Transactions::API::AssignModelUser(key: :user)
  step Policy::Pundit(EventManager::Workflows::Policy, :create?)
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Event created successfully')

  def build_contract(input, options)
    contract = EventManager::Master.contract_for(options[:params]&.dig(:trigger_type), options[:model])
    if contract.nil?
      on_error(options, :trigger_type, 'is invalid')
      return nil
    end
    contract
  end

end
