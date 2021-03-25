class Docs::P2P::Invoices::Policy < ApplicationPolicy

  def create?
    user.present? && user.company.id == record.company_id && user.is_non_po_invoice_initiator? 
  end

  def show?
    if user.present? && user.company.id == record.company_id
    
      return true if record.validate_if_owner(user)
      return true if record.validate_if_admin(user)
      return true if record.validate_if_reviewer(user) # For DLRMS reviewers

      if record.procurement.present? && record.procurement.purchase_order.present?
        return true if  record.validate_if_po_invoice_auditor(user)
        return true if  record.validate_if_po_invoice_reviewer(user)
      end

      if record.procurement.blank? || record.procurement.purchase_order.blank?
        return true if record.validate_if_non_po_invoice_auditor(user)
        return true if record.validate_if_non_po_invoice_reviewer(user)
      end

      return true if user.is_bank_payment_request_initiator?
      return true if user.is_bank_payment_request_reviewer?
      return true if user.is_bank_payment_request_creditor?
      return true if user.is_credit_note_initiator?
      return true if user.is_credit_note_reviewer?
      return true if user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor?
      
    end
    return false
    # todo - I2P check invoice permissions `app/operations/procurements/invoices/show.rb`
  end

  def update?
    if user.present? && user.company.id == record.company_id 
      # if the document is retracted or in draft
      if InwardInvoiceStatus.ids_for([:open, :retracted]).include?(record.invoice_status_id)
        return true if record.validate_if_owner(user)
      # else if the doc is in processing 
      elsif record.processing?
        return true if record.validate_if_admin(user)
        return true if record.validate_if_reviewer(user)
      end
    end
    return false
  end

  def review?
    return false if user.blank?

    record.processing? && record.controlling_user?(user)
  end

  def take_control?
    return false if user.blank?
    return false if record.action_users(:approve).include?(user)

    record.processing? && user.vendor_payment_admin? && (record.dlrms&.find_by(level_id: record.level&.id)&.taken_control_by_id != user.id rescue false)
  end

  def erp_sync?
    # Limiting it to admins only as this
    user.admin?(:vp)
  end

end