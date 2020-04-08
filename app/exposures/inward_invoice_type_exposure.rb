class InwardInvoiceTypeExposure < Exposures::API

  def name
    record.name.humanize
  end

end