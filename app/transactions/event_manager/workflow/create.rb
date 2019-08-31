class EventManager::Workflow::Create < Transactions::API

  step Model(EventWorkflow, :new)
  step Transaction::AssignModelUser(key: :user)
  step Policy::Pundit(EventManager::Workflow::Policy, :create?)
  step Contract::Build(builder: :build_contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transaction::SuccessMessage('Event created successfully')

  def build_contract(input, options)
    contract = EventManager::Config.contract_for(options[:params]&.dig(:trigger_type), options[:model])
    if contract.nil?
      on_error(options, :trigger_type, 'is invalid')
      return nil
    end
    contract
  end

end
