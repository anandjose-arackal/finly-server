class InwardInvoiceTypeExposure < Exposures::API

  attribute :name do
    record.name.titleize
  end

  attribute :key do
    record.name
  end

end