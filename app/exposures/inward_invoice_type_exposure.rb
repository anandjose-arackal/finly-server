class InwardInvoiceTypeExposure < Exposures::API

  attribute :name do
    case record.name
    when 'tax_invoice'
      'PO Invoice'
    when 'recurring_invoice'
      'Agreement Invoice'
    else
      record.name.titleize
    end
  end

  attribute :key do
    record.name
  end

end