class ImportJobExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :type, record_attribute: true
  attribute :created_by, record_attribute: true, exposure: true, includes: [:created_by]
  attribute :request_params, record_attribute: true
  attribute :completed_at, record_attribute: true
  attribute :total_records, record_attribute: true
  attribute :created_records, record_attribute: true
  attribute :updated_records, record_attribute: true
  attribute :skipped_records, record_attribute: true
  attribute :failed_records, record_attribute: true
  attribute :completed_records, record_attribute: true
  attribute :completion_percentage, record_attribute: true
  attribute :attachment_url do
    record.attachment&.url
  end
  attribute :options, record_attribute: true
  attribute :status, record_attribute: true, exposure: true, includes: [:status]

end