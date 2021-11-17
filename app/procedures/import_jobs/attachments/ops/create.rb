class ImportJobs::Attachments::Ops::Create < Transactions::API
  step Model(ImportJobAttachment, :new)
  step Transactions::API::AssignModelUser(key: :created_by)
  step Contract::Build(constant: ImportJobs::Attachments::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Import Job Attachment created')
end
