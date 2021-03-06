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

  # procurement action config type in fe based on this config_key
  attribute :config_key do
    case record.name
    when 'recurring_invoice'
      'non_po_invoice'
    else
      record.name
    end
  end

end