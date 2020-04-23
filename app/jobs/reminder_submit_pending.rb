class ReminderSubmitPending < ApplicationJob
  def perform
    # remind_submit_pending_grn
    # remind_submit_pending_invoice

    remind_document_submission
  end

  # def remind_submit_pending_grn
  #   created_at_date = 30.days.ago.to_date
  #   params = {}
  #   params[:filter_procurement_type] = "purchase_order"
  #   params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]
  #   User.where(company_id: 156).each do |user|
  #     # params[:inward_documents] = user.inward_documents.where(where("DATE(created_at) >= ?", created_at)) }
  #     grn_ids = Procurements::Grn::Pending::Index.(user, params).procurements.where("DATE(procurements.created_at) >= ?", created_at_date).joins(:inward_documents).where("inward_documents.user_id", user.id).pluck('inward_documents.id') rescue nil
  #     inward_documents = user.company.inward_documents.where(id: grn_ids) rescue nil
  #     params[:inward_documents] = inward_documents
  #     Event::EInwardDocument::SubmitPending.(user, params) if params.fetch(:inward_documents).present?
  #   end
  # end

  # def remind_submit_pending_invoice
  #   created_at_date = 30.days.ago.to_date
  #   User.where(company_id: 156).each do |user|
  #     params = { invoices:  user.inward_invoices.where(invoice_status_id: InwardInvoiceStatus.id_for(:open)).where("DATE(created_at) >= ?", created_at) }
  #     Event::EInvoice::SubmitPending.(user, params) if params.fetch(:invoices).present?
  #   end
  # end

  private
  def self.remind_document_submission
    created_at = 30.days.ago.to_date
    # Get users with initiator role
    initiator_role_ids = [UserRole.id_for(:goods_receiver), UserRole.id_for(:invoice_initiator)]
    initiator_ids = Policy.where(company_id: 156).joins(:policy_user_roles).where('policy_user_roles.user_role_id IN (?)', initiator_role_ids).pluck('policy_user_roles.user_id').uniq

    if initiator_ids.present?
      User.where(company_id: 156).where(id: initiator_ids).each do |user|
        if user.email.present?
          params = {}
          params[:filter_procurement_type] = "purchase_order"
          params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]
          grn_ids = Procurements::Grn::Pending::Index.(user, params).procurements.where("DATE(procurements.created_at) >= ?", created_at).joins(:inward_documents).where("inward_documents.user_id = ?", user.id).pluck('inward_documents.id') rescue nil
          inward_documents = user.company.inward_documents.where(id: grn_ids) rescue nil
          params[:inward_documents] = inward_documents
          params[:po_invoices] = user.inward_invoices.where(invoice_status_id: InwardInvoiceStatus.id_for(:open)).where("DATE(created_at) >= ?", created_at).filter_invoice_type('po_invoice') rescue nil
          params[:non_po_invoices] = user.inward_invoices.where(invoice_status_id: InwardInvoiceStatus.id_for(:open)).where("DATE(created_at) >= ?", created_at).filter_invoice_type('non_po_invoice') rescue nil

          Event::EDocument::RemindPendingSubmit.(user, params) if params.values.present?
        end
      end
    end
  end

end