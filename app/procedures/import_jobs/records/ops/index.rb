class ImportJobs::Records::Ops::Index < Transactions::API
  step Model(ImportJob, :find_by_uuid)
  step :set_filter_params
  step Resolver::Transactions::Load(klass: ImportJobs::Records::Resolver, paginate: true)
  step :set_status_counts
  step :set_total_count

  def set_filter_params(context, params:, model:, current_user:, **)
    params[:q] = {}
    if params[:status_id].present?
      params[:q][:status_id_eq_any] = params[:status_id]
    end

    true
  end

  def set_status_counts(context, model:, current_user:, **)
    statuses = [{
      id: nil,
      name: 'all',
      count: model&.records&.count || 0
    }]
    ImportJobStatus.all.each do |status|
      statuses << {
        id: status.id,
        name: status.name,
        count: model&.records&.with_status_id(status.id)&.count || 0
      }
    end

    context['statuses'] = statuses

    true
  end

  def set_total_count(context, model:, params:, current_user:, **)
    filter_records = ImportJobs::Records::Resolver.(params: params.merge(filter: true, paginate: false), current_user: current_user)
    context['count'] = filter_records&.count
    true
  end

end
