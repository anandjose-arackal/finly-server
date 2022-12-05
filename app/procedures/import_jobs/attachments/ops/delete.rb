class ImportJobs::Attachments::Ops::Delete < Transactions::API
  step Model(ImportJobAttachment, :find_by_uuid)
  step :delete_attachment
  step Transactions::Messages::SuccessMessage('Import Job Attachment deleted')

  def delete_attachment(context, model:, current_user:, **)
    model.destroy
    true
  end
end