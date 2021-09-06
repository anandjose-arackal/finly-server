class Docs::AuditTrails::Resolver < Resolver::API

  entity ::AuditTrail

  def load(params)
    if params[:filter_ids].present?
      ::AuditTrail.where(item_type: ::AuditTrail.parent_document_types).where(company_id: user.company_id).where(user_transaction_id: params[:filter_ids]).group(:user_transaction_id)
    else
      ::AuditTrail.where(item_type: ::AuditTrail.parent_document_types).where(company_id: user.company_id).group(:user_transaction_id)
    end
  end

end