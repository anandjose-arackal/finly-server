class Analytics::Synchronizer < Transactions::API

  schema do
    params do
      required(:record).filled
      required(:olap_model)
      optional(:olap_record)
      optional(:payload)
    end
  end

  skip_user_authorization!

  pass :init
  step :init_model
  step :can_update_check
  step Contract::Build(builder: :contract_builder)
  step Contract::Validate()


  def init(context, params:, **)
    context[:record] = params[:record]
    context[:olap_model] = params[:olap_model]
    context[:olap_record] = params[:olap_record]
    context[:payload] = params[:payload]
  end

  def init_model(context, params:, olap_model:, olap_record:, record:, **)
    context[:model] = olap_record
    return true if context[:model]

    context[:model] = olap_model.find_or_initialize_by(finly_ref_id: record.id)

    return on_error context, :base, 'Model could not be initialized' if context[:model].nil?
    true
  end

  def can_update_check(context, model:, record:,payload: **)
    if model.in_sync?(record, payload)
      context[:in_sync] = true
      return false
    end
    true
  end

  def contract_builder(context, model:, record:, **)
    model.build_contract(record)
  end

  class Analytics::Synchronizer::Persist < Analytics::Synchronizer
    step Contract::Persist()
  end

  class Analytics::Synchronizer::Sync < Analytics::Synchronizer
    step Contract::Persist(method: :sync)
  end

end
