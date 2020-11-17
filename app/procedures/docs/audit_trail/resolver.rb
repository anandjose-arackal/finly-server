class Docs::AuditTrail::Resolver < Resolver::API

  entity PaperTrail::Version

  def load(params)
    PaperTrail::Version.where(company_id: user.company_id)
  end

end