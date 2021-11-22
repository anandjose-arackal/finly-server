class ImportJobs::Ops::Create < Transactions::API
  step Model(ImportJob, :new)
  step Transactions::API::AssignModelUser(key: :created_by)
  step Contract::Build(constant: ImportJobs::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step :run_preprocessing_job
  step :set_meta_data
  step Transactions::Messages::SuccessMessage('Import Job created')


  def run_preprocessing_job(context, model:, current_user:, **)
    ImportJobs::Router.dispatch(model.options['route'], {params: {id: model.id, uuid: model.id, route: model.options['route'], preprocess_import_job: true}, current_user: current_user}, async=true)

    true
  end

  def set_meta_data(context, model:, current_user:, **)
    ImportJobs::Router.dispatch(model.options['route'], {params: {id: model.id, uuid: model.id, route: model.options['route'], process_meta_data: true}, current_user: current_user})
    model.reload

    true
  end

end