class Docs::AuditTrails::Resolver < Resolver::API

  entity ::AuditTrail

  def load(params)
    ::AuditTrail.order(created_at: :desc).non_deleted.where(company_id: user.company_id)
  end

end