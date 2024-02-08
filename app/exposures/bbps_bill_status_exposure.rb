class BbpsBillStatusExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :name do
    record.name.titleize
  end

end