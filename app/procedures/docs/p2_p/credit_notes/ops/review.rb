class Docs::P2P::CreditNotes::Ops::Review < Transactions::API

  schema do
    params do
      required(:aasm_event).filled
    end
  end

  step :init
  step Model(CreditNote, :find_by)
  step :verify_policy
  step :transition

  fail :check

  def init(options, params:, **)
    params[:id] = params[:credit_note_id]
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
    }
    op = WorkflowManager::Base.(current_user, parameters)
    unless op.success?
      add_message(options, :error, :base, op.messages.errors)
    end
    op.success?
  end


  def check(options, params:, **)
  end
end