class ProcurementExposure < Exposures::API

  include Concerns::ErpSyncConcern

  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :note, record_attribute: true
  attribute :vendor, record_attribute: true
  attribute :company, record_attribute: true

end