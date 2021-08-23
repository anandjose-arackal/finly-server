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
  step :validate_uniquness
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

  def validate_subscription_uniqueness
    unique_subscription =  BbpsBillerSubscription.filter_unique_check.where.not(id: model.id).where(bbps_biller_id: model.bbps_biller_id,
                                                                                              customer_param_key_1: model.customer_param_key_1,
                                                                                              customer_param_value_1: model.customer_param_value_1,
                                                                                              customer_param_key_2: model.customer_param_key_2,
                                                                                              customer_param_value_2: model.customer_param_value_2,
                                                                                              customer_param_key_3: model.customer_param_key_3,
                                                                                              customer_param_value_3: model.customer_param_value_3,
                                                                                              customer_param_key_4: model.customer_param_key_4,
                                                                                              customer_param_value_4: model.customer_param_value_4,
                                                                                              customer_param_key_5: model.customer_param_key_5,
                                                                                              customer_param_value_5: model.customer_param_value_5).first
    if unique_subscription.present?
      add_message options, :error, :base, "Active Subscription already exist for this biller with Subscription ID #{unique_subscription.sequence_id}"
      return
    end
    true
  end
end