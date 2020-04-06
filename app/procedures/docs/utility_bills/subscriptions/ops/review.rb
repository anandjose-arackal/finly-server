class Docs::UtilityBills::Subscriptions::Ops::Review < Transactions::API

  schema do
    params do
      required(:aasm_event).filled
    end
  end

  step :init
  step Model(BbpsBillerSubscription, :find_by)
  step :verify_policy
  # step :set_default_params
  step :transition
  step :post_process

  fail :check

  # step Transactions::Messages::SuccessMessage("You have successfully")

  # step :success_message
  #
  # def success_message(options)
  #   add_message options, :success, :base, "You have successfully ..."
  # end

  def init(options, params:, **)
    params[:id] = params[:subscription_id]
    true
  end

  def verify_policy(options, current_user:, params:, model:, **)
    policy = Docs::UtilityBills::Subscriptions::Authorizer.new(current_user, model)

    success = policy.send((params[:aasm_event].to_s + '?').to_sym)

    unless success
      return false
    end

    true
  end

  def transition(options, params:, current_user:, model:, **)
    parameters = {
        document: model,
        aasm_event: params[:aasm_event],
    }
    op = WorkflowManager::Base.(current_user, parameters)

    op.success?
  end

  def post_process(options, params:, model:, **)
    if params[:note].present?
      model.update(review_note: params[:note])
    end
    true
  end


  def check(options, params:, **)
  end
end