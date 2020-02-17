class Docs::P2P::CreditNotes::Ops::Review < Transactions::API

  schema do
    params do
      required(:aasm_event).filled
    end
  end

  step :init
  step Model(CreditNote, :find_by)
  step :validation
  step :verify_policy
  step :transition

  fail :check

  def init(options, params:, **)
    params[:id] = params[:credit_note_id]
    true
  end

  def validation(options, params:, model:, **)
    if params[:aasm_event].to_s == 'reject'
      if params[:reject_to_user].present? && params[:reject_to_level].present?
        reject_to_details = model.reject_to_users

        if reject_to_details[params[:reject_to_level].to_i].blank? && (reject_to_details[params[:reject_to_level].to_i].try(:id) != params[:reject_to_user])
          add_message :error, :error, :base, "User details not found for this level"
        end
      end
    end
    true
  end

  def verify_policy(options, current_user:, params:, model:, **)
    policy = Docs::P2P::CreditNotes::Authorizer.new(current_user, model)

    success = policy.send((params['aasm_event'].to_s + '?').to_sym)

    unless success
      return false
    end


    true
  end

  def transition(options, params:, current_user:, model:, **)
    parameters = {
        document: model,
        aasm_event: params[:aasm_event],
        reject_to_user: params[:reject_to_user],
        reject_to_level: params[:reject_to_level]

    }
    op = WorkflowManager::Base.(current_user, parameters)

    op.messages.slice(:error, :success, :info).each do |key, val|
      next if key == :errors_meta
      add_message options, key, :base, val
    end

    op.success?
  end


  def check(options, params:, **)
  end
end