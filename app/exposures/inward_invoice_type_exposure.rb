class InwardInvoiceTypeExposure < Exposures::API

  attribute :name do
    record.name.humanize
  end

  attribute :key do
    record.name
  end

end