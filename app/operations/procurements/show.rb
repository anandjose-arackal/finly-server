class Procurements::Show < Procurements::Base
  attr_accessor :procurement

  def init
    id = params[:id] || params[:procurement_id]
    self.procurement = user.company.procurements.find_by id: id
  end

  def validate
    if procurement.blank? || procurement.company_id != user.company_id
      add_message :error, 'Record not found'
      return
    end
  end

  def process
  end

  def success
    params[:procurement] = self.procurement
    Procurements::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurement, :purchase_order, :invoices, :inward_documents, :procurement_trail, :locations,
                  :payment_terms, :bill_of_supplies, :delivery_challans, :vendor,
                  :procurement_terms, :policies, :e_way_bills, :status_tags, :actions, :po_revisions

    def init
      self.procurement = params[:procurement]

      # Procurement Documents
      self.purchase_order = self.procurement.purchase_order
      self.vendor = get_vendor
      self.invoices = self.procurement.invoices
      self.inward_documents = self.procurement.inward_documents
      self.bill_of_supplies = self.procurement.bill_of_supplies
      self.delivery_challans = self.procurement.delivery_challans
      self.e_way_bills = self.procurement.e_way_bills
      self.po_revisions = self.procurement.po_revisions

      self.procurement_trail = get_procurement_trail
      self.locations = user.company.locations
      self.payment_terms = user.company.payment_terms
      self.procurement_terms = user.company.procurement_terms
      self.status_tags = self.procurement.status_tags.reverse
      self.actions = get_actions
      params[:filter_role_id] = [UserRole.id_for(:purchase_order_initiator), UserRole.id_for(:invoice_initiator), UserRole.id_for(:goods_receiver)]
      policies_op = Policy::VendorPayments::Index.(user, params)
      if policies_op.success?
        self.policies = policies_op.policies
      end

      # self.grn_items = self.inward_documents.last.all_items_accepted?

    end

    def get_actions
      actions = {}
      if po_revisions.present?
        if (po_revisions.last.approved? || po_revisions.last.auto_approved? || po_revisions.last.sent_to_vendor?) && (user_in_level? || document_owner?)
          actions[:add_document] = true
        end
      elsif purchase_order.present?
        if (purchase_order.approved? || purchase_order.auto_approved? || purchase_order.sent_to_vendor? || purchase_order.all_items_accepted?) && (user_in_level? || document_owner?)
          actions[:add_document] = true
        end
      end
      actions
    end

    def get_vendor
      case procurement.procurement_type
        #todo write migration for all existing procurements
        when 'purchase_order'
          vendor = self.procurement.purchase_order.vendor
        when 'invoice'
          vendor = self.procurement.invoices.first.vendor
        else
          return nil
      end

      vendor
    end

    def document_owner?
      purchase_order.user_id == user.id
    end

    def user_in_level?
      current_level = purchase_order.level
      amount = purchase_order&.balance_amount&.value || 0

      if current_level.present?
        if current_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include? user.id
          return true
        end
      end

      false
    end

    def get_procurement_trail
      documents = []
      result = []

      if self.purchase_order.present?
        documents << self.purchase_order
      end

      documents += self.inward_documents
      documents += self.invoices
      documents += self.purchase_order&.advance_payments if self.purchase_order.present?

      self.invoices.each do |invoice|
        documents += invoice.payments
      end
      documents += self.bill_of_supplies
      documents += self.delivery_challans
      documents += self.e_way_bills
      documents += self.po_revisions

      documents.sort_by!{ |doc| doc.created_at}.reverse!
      documents
    end
  end

end