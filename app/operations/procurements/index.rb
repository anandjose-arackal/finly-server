class Procurements::Index < Procurements::Base
  attr_accessor :procurements

  def init

  end

  def process
    # Find trail user for invoice

    procurement_ids = []

    # Find procurement from invoice trails
    invoice_trails = Trail.with_action_user_id(user.id).with_parent_type('Invoice')
    procurement_ids += user.company.inward_invoices.with_id(invoice_trails.pluck(:parent_id)).pluck(:procurement_id).uniq


    # Find procurement from purchase order trails
    purchase_order_trails = Trail.with_action_user_id(user.id).with_parent_type('PurchaseOrder')
    procurement_ids += user.company.purchase_orders.with_id(purchase_order_trails.pluck(:parent_id)).pluck(:procurement_id).uniq


    # Find own procurements
    if user.vendor_payments_initiator?
      procurement_ids += user.company.purchase_orders.with_user_id(user.id).pluck(:procurement_id)
    end

    # If reviewer or awaiting reviewal
    if user.vendor_payments_reviewer?
      level_ids = LevelReviewerMapping.with_reviewer_id(user.id).pluck(:level_id)

      # policies = user.company.policies.with_application(:vp)
      # policies.each do |policy|
      #   levels = policy.levels
      #   levels.each do |level|
      #     if level.reviewers.pluck(:id).include? user.id
      #       level_ids.push(level.id)
      #     end
      #   end
      # end

      # For PO
      # procurement_ids.push(user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:procurement_id))

      purchase_order_ids = user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:id)
      # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
      other_reviewer_po_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('PurchaseOrder').pluck(:document_reviewer_mappable_id)
      purchase_order_ids -= other_reviewer_po_ids
      procurement_ids += user.company.purchase_orders.with_id(purchase_order_ids).pluck(:procurement_id)

      # For Invoice
      # procurement_ids.push(user.company.inward_invoices.with_controlling_level_ids(level_ids).pluck(:procurement_id))

      invoice_ids = user.company.inward_invoices.with_controlling_level_ids(level_ids).pluck(:id)
      # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
      other_reviewer_invoice_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('Invoice').pluck(:document_reviewer_mappable_id)
      invoice_ids -= other_reviewer_invoice_ids
      procurement_ids += user.company.inward_invoices.with_id(invoice_ids).pluck(:procurement_id)
    end


    # If creditor: find approved, unpaid, partially paid, paid invoices and their procurements
    invoice_status_ids = [InwardInvoiceStatus.id_for(:approved), InwardInvoiceStatus.id_for(:unpaid), InwardInvoiceStatus.id_for(:partially_paid), InwardInvoiceStatus.id_for(:paid)]
    procurement_ids += user.company.inward_invoices.with_procurement.with_status_id(invoice_status_ids).pluck(:procurement_id)

    # If admin, select all procurements
    if user.vendor_payment_admin?
      procurement_ids += user.company.purchase_orders.pluck(:procurement_id)
    end

    self.procurements = user.company.procurements.with_ids(procurement_ids.uniq).include_details

  end

  def success
    params[:procurements] = self.procurements
    Procurements::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements, :paginated_procurements

    has_scope :filter_status_tags, type: :array
    has_scope :filter_vendor_name, :filter_po_number, :filter_invoice_number

    def init
      self.procurements = params[:procurements]
      apply_filter
      self.paginated_procurements = self.procurements.order_by_controlling_level(user.id)
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_procurements = self.paginated_procurements.paginate(page: page, per_page: per_page)
    end

    def apply_filter
      if params[:search_type].present? && params[:search_query].present?
        set_scope
        self.procurements = apply_scopes(self.procurements, params)
      end
    end

    def awaiting_action?(procurement)
    end
    
    def set_scope
      case params[:search_type]
        when 'vendor_name'
          params[:filter_vendor_name] = params[:search_query]
        when 'invoice_number'
          params[:filter_invoice_number] = params[:search_query]
        when 'po_number'
          params[:filter_po_number] = params[:search_query]
        else
          # do nothing
      end
    end

  end
end