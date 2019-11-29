class Analytics::Synchronizer < Transactions::API

  schema do
    params do
      required(:record).filled
      required(:olap_model)
      optional(:olap_record)
    end
  end

  skip_user_authorization!

  pass :init
  step :init_model
  step :can_update_check
  step Contract::Build(builder: :contract_builder)
  step Contract::Validate()
  step Contract::Persist()

  def init(context, params:, **)
    context[:record] = params[:record]
    context[:olap_model] = params[:olap_model]
    context[:olap_record] = params[:olap_record]
  end

  def init_model(context, params:, olap_model:, olap_record:, record:, **)
    context[:model] = olap_record || olap_model.find_or_initialize_by(finly_ref_id: record.id)
    return on_error context, :base, 'Model could not be initialized' if context[:model].nil?
    true
  end

  def can_update_check(context, model:, record:, **)
    if model.finly_ref_updated_at == record.updated_at
      context[:in_sync] = true
      return false
    end
    true
  end

  protected

  def contract_builder(context, olap_model:, **)
    olap_model.contract.new(context[:model])
  end

end
