class Masters::ProcurementTerms::Resolver < Resolver::API

  entity PurchaseOrderStatus

  def load(params)
    user.company.procurement_terms || []
  end
end