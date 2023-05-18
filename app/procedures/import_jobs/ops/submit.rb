class ImportJobs::Ops::Submit < Transactions::API
  step Model(ImportJob, :find_by_uuid)
  step :save_current_record
  pass :run_background_job
  step Transactions::Messages::SuccessMessage('Import in progress')

  def save_current_record(context, params:, current_user:, **)
    params['id'] = params['import_record_id']
    op = ImportJobs::Records::Ops::Update.(params: params, current_user: current_user)
    return true if op.success?
  end
  def run_background_job(context, model:, current_user:, **)
    ImportJobs::Router.dispatch(model.options['route'], {params: {id: model.id, uuid: model.id, route: model.options['route'], process_import: true}, current_user: current_user}, async = false)
  end
end