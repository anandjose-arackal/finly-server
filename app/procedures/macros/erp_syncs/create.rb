class Macros::ErpSyncs::Create < Transactions::API

  step Model(ErpSyncAttempt, :new)
  step :init_record
  pass :init_current_user
  step :authorize!
  step Contract::Build(constant: Macros::ErpSyncs::Contracts::Create)
  step Contract::Validate()
  step Contract::Persist()
  step :update_record_sync_status
  step Transactions::Messages::SuccessMessage('Saved')

  def init_record(context, record_class:, params:, **)
    key = context[:record_key] || :id
    context[:record] = params[:record] = record_class.find_by(id: params[key])
    return on_error(context, :record, 'not found') if params[:record].blank?

    true
  end

  def init_current_user(context, params:, current_user:, **)
    params[:current_user] = current_user
    params[:company] = current_user&.company
  end

  def authorize!(context, policy:, model:, current_user:, **)
    return on_error context, :policy, 'not found' if policy.blank?

    policy_klass, permission = policy
    unless policy_klass.new(current_user, model).send(permission)
      return Authorize.unauthorized!(context)
    end

    true
  end

  def update_record_sync_status(context, model:, record:, **)
    record.update(
        erp_sync_status_id: model.status_id,
        erp_sync_message: model.message,
        erp_sync_reference_id: model.reference_id,
        erp_sync_attempted_at: model.attempted_at,
        erp_sync_attempts_count: record.erp_sync_attempts.count
    )
  end

end