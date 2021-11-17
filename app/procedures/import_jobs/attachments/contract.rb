class ImportJobs::Attachments::Contract < Reform::Form
  property :import_job_id
  property :created_by_id
  property :company_id, validates: { presence: true }
  property :attachment, validates: {presence: true}

  property :identifier, deserializer: -> (input, represented, **) {
    if input[:identifier].present?
      represented.identifier = input[:identifier]
    else
      represented.identifier = represented.attachment&.original_filename
    end
  }
end
