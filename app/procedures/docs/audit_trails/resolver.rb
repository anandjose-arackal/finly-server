class Docs::AuditTrails::Resolver < Resolver::API

  entity ::AuditTrail

  def load(params)
    ::AuditTrail.where(item_type: ::AuditTrail.parent_document_types).where(company_id: user.company_id).group(:transaction_id)
  end

end