class Docs::AuditTrail::Resolver < Resolver::API

  entity ::AuditTrail

  def load(params)
    ::AuditTrail.non_deleted.where(company_id: user.company_id)
  end

end