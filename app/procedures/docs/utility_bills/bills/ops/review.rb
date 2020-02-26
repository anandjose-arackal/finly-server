class Docs::UtilityBills::Bills::Ops::Review < Transactions::API

  step :init
  step Model(BbpsBill, :find_by)
  step :verify_policy
  # step :set_default_params
  step :transition
  step :post_process

  fail :check

  def init(options, params:, **)
    params[:id] = params[:bill_id]

  end

  def verify_policy(options, current_user:, params:, model:, **)
    policy = Docs::UtilityBills::Bills::Authorizer.new(current_user, model)

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
    op.messages.slice(:error, :success, :info).each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

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