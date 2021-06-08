class Masters::InwardInvoiceStatuses::Resolver < Resolver::API

  entity InwardInvoiceStatus

  def load(params)
    InwardInvoiceStatus.all
  end

end