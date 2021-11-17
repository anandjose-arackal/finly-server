class ImportJobs::Records::Ops::Update < Transactions::API
  step Model(ImportRecord, :find_by_uuid)
  step Contract::Build(constant: ImportJobs::Records::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Import Record Updated')
end