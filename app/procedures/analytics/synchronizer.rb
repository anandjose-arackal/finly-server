class Analytics::Synchronizer < Transactions::API

  schema do
    params do
      required(:mapper).filled
      required(:record).filled
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
    context[:mapper] = params[:mapper]
  end

  def init_model(context, params:, mapper:, record:, **)
    context[:model] = mapper.olap_model.find_or_initialize_by(finly_ref_id: record.id)
    return on_error context, :base, 'Model could not be initialized' if context[:model].nil?
    true
  end

  def can_update_check(context, model:, record:, **)
    if model.finly_ref_updated_at == record.updated_at
      context[:updated] = false
      return false
    end
    true
  end

  protected

  def contract_builder(context, mapper:, **)
    mapper.contract.new(context[:model])
  end

end
