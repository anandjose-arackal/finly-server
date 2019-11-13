class Docs::UtilityBills::Subscriptions::Ops::ValidateCustomerParams < Trailblazer::Operation


  step :init
  # step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :update? )
  # # step :set_default_params
  # step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Update)
  # step Contract::Validate(key: 'subscription')
  # failure :check
  # step Contract::Persist()

  def init(options)
    options['result'] = {}

    if rand > 0.5
      options['result']['success'] = true
    else
      options['result']['success'] = false
      options['result']['messages'] = {
          'errors' => ['No record found with the provided data']
      }
    end

  end
end