class ProcurementTermExposure < Exposures::API
  include Concerns::ErpSyncConcern
  attribute :id, record_attribute: true
  attribute :name, record_attribute: true
  attribute :text do
    record.description
  end
end
