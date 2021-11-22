class ImportJobs::Records::Ops::Show < Transactions::API
  step Model(ImportRecord, :find_by_uuid)
  step :set_preprocessed_data

  def set_preprocessed_data(context, model:, current_user:, **)
    import_job = model.import_job
    if model.processed_data.nil?
      ImportJobs::Router.dispatch(import_job.options['route'], {params: {id: import_job.id, uuid: import_job.id, route: import_job.options['route'], record_id: model.uuid, preprocess_import_record: true}, current_user: current_user})
    end

    model.reload
    true
  end
end