class VendorStatusExposure < Exposures::API

  attribute :name do
    record.name.humanize
  end

end