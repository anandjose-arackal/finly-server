class VendorStatusExposure < Exposures::API

  attribute :name do
    record.name.titleize
  end

end