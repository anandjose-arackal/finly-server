class Docs::UtilityBills::Subscriptions::Ops::Update < Transactions::API

  # schema do
  #   params do
  #     # Todo filled from user
  #     required(:subscription) do
  #       required(:subscription_pocs) do
  #         hash do
  #           required(:user_id).filled
  #         end
  #       end
  #     end
  #   end
  # end

  step :set_default_params
  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :update? )
  failure :check
  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Base)
  step Contract::Validate(key: 'subscription')

  failure :check2
  step Contract::Persist()

  def check(options, **)
  end

  def check2(options, **)
  end

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:current_user] = current_user
  end
end