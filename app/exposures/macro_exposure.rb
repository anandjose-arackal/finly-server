class MacroExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :macro_id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :description, record_attribute: true
  attribute :script, record_attribute: true
  attribute :macro_type, record_attribute: true, exposure: true, includes: [:macro_type]
  attribute :active, record_attribute: true
  attribute :company, record_attribute: true, exposure: true, includes: [:company]
  attribute :user, record_attribute: true, exposure: true, includes: [:user]
  attribute :created_by, record_attribute: true, exposure: true, includes: [:created_by]
  attribute :created_by_admin, record_attribute: true, exposure: true, includes: [:created_by_admin]
  attribute :last_run_at, record_attribute: true
  attribute :deleted_at, record_attribute: true
  attribute :created_at, record_attribute: true
  attribute :updated_at, record_attribute: true

end