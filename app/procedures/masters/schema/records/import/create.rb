class Masters::Schema::Records::Import::Create < Transactions::API
  include Transactions::BackgroundWorker

  step RecordModelClass()
  step Policy::Pundit(Masters::Schema::Records::Policy, :import?)
  step Contract::Build(constant: Masters::Schema::Records::Import::Contract)
  step Contract::Validate()
  step Contract::Persist()
  pass :run_background_job
  step Transactions::Messages::SuccessMessage('Import in progress')

  def run_background_job(context, model:, current_user:, **)
    Masters::Schema::Records::Import::Job.call_async(params: {id: model.id}, current_user: current_user)
  end

end