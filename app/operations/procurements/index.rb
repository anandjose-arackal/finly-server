class Procurements::Index < Procurements::Base
  attr_accessor :procurements

  def init

  end

  def process
      # For grn index page, consider only inward document based procurement and it's PO
      # if params[:filter_status_tags].present?
      #   && ( [StatusTag.id_for(:receiving_shipment),  StatusTag.id_for(:shipment_received)].include?(params[:filter_status_tags]) )
      #     && (user.is_goods_receiver? || user.vp_admin_or_auditor?)
      #   self. procurements = user.company.procurements.joins(:inward_documents)&.distinct
      # return
      # end

    if user.vp_admin_or_auditor?
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      self.procurements = user.company.procurements.with_ids(::PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})&.pluck(:procurement_id)&.uniq).or(user.procurements)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      # 'Model.none' returns blank active record relation
      self.procurements = user.company.procurements.with_ids(::PurchaseOrder.associated_items(user, resource_roles= ::PurchaseOrder.roles)&.pluck(:procurement_id)&.uniq) rescue ::Procurement.none
      # For Tax invoice/Inward invoice
      self.procurements = procurements.or(user.company.procurements.with_ids(::Invoice.associated_items(user, resource_roles= ::Invoice.roles)&.pluck(:procurement_id)&.uniq)) rescue ::Procurement.none
      # For inward document/ Goods receiver
      self.procurements = procurements.or(user.company.procurements.with_ids(::InwardDocument.associated_items(user, resource_roles= ::InwardDocument.roles)&.pluck(:procurement_id)&.uniq)) rescue ::Procurement.none
      # If user is bank payment request creditor in the policy
      if user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
        invoice_status_ids = [InwardInvoiceStatus.id_for(:approved), InwardInvoiceStatus.id_for(:unpaid), InwardInvoiceStatus.id_for(:partially_paid), InwardInvoiceStatus.id_for(:paid)]
        policy_ids = user.company.policies.joins(:policy_user_roles)&.where("(policy_user_roles.user_id = ?) && (policy_user_roles.user_role_id = ?)", user.id, UserRole.id_for(:bank_payment_request_creditor))&.pluck(:id)
        self.procurements = procurements.or(Procurement.where(id: user.company.inward_invoices.where(policy_id: policy_ids).with_procurement.with_status_id(invoice_status_ids).pluck(:procurement_id)))
      end
    else
      # Nullify
      self.procurements = PurchaseOrder.none
    end
    # # Find trail user for invoice

    # procurement_ids = []

    # # Find procurement from invoice trails
    # invoice_trails = Trail.with_action_user_id(user.id).with_parent_type('Invoice')
    # procurement_ids += user.company.inward_invoices.with_id(invoice_trails.pluck(:parent_id)).pluck(:procurement_id).uniq


    # # Find procurement from purchase order trails
    # purchase_order_trails = Trail.with_action_user_id(user.id).with_parent_type('PurchaseOrder')
    # procurement_ids += user.company.purchase_orders.with_id(purchase_order_trails.pluck(:parent_id)).pluck(:procurement_id).uniq


    # # Find own procurements
    # if user.vendor_payments_initiator?
    #   procurement_ids += user.company.purchase_orders.with_user_id(user.id).pluck(:procurement_id)
    #   procurement_ids += user.company.inward_invoices.with_procurement.with_created_by_user_id(user.id).pluck(:procurement_id)
    # end

    # # If reviewer or awaiting reviewal
    # if user.vendor_payments_reviewer?
    #   #todo lrm
    #   level_ids = LevelReviewerMapping.with_reviewer_id(user.id).pluck(:level_id)

    #   # policies = user.company.policies.with_application(:vp)
    #   # policies.each do |policy|
    #   #   levels = policy.levels
    #   #   levels.each do |level|
    #   #     if level.reviewers.pluck(:id).include? user.id
    #   #       level_ids.push(level.id)
    #   #     end
    #   #   end
    #   # end

    #   # For PO
    #   # procurement_ids.push(user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:procurement_id))
    #   purchase_order_ids = user.company.purchase_orders.with_controlling_level_ids(level_ids).pluck(:id)
    #   # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
    #   other_reviewer_po_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('PurchaseOrder').pluck(:document_reviewer_mappable_id)
    #   purchase_order_ids -= other_reviewer_po_ids
    #   procurement_ids += user.company.purchase_orders.with_id(purchase_order_ids).pluck(:procurement_id)

    #   # For Invoice
    #   # procurement_ids.push(user.company.inward_invoices.with_controlling_level_ids(level_ids).pluck(:procurement_id))

    #   invoice_ids = user.company.inward_invoices.with_controlling_level_ids(level_ids).pluck(:id)
    #   # Find all document level reviewer mappings with above list of level + NOT reviewer and their pos
    #   other_reviewer_invoice_ids = ::DocumentLevelReviewerMapping.with_level_ids(level_ids).not_with_reviewer_ids(user.id).with_document_type('Invoice').pluck(:document_reviewer_mappable_id)
    #   invoice_ids -= other_reviewer_invoice_ids
    #   procurement_ids += user.company.inward_invoices.with_id(invoice_ids).pluck(:procurement_id)
    # end

    # If creditor: find approved, unpaid, partially paid, paid invoices and their procurements
    # if user.vendor_payment_creditor?
    #   invoice_status_ids = [InwardInvoiceStatus.id_for(:approved), InwardInvoiceStatus.id_for(:unpaid), InwardInvoiceStatus.id_for(:partially_paid), InwardInvoiceStatus.id_for(:paid)]
    #   procurement_ids += user.company.inward_invoices.with_procurement.with_status_id(invoice_status_ids).pluck(:procurement_id)
    # end

    # # If admin, select all procurements
    # if user.vendor_payment_admin?
    #   procurement_ids += user.company.purchase_orders.pluck(:procurement_id)
    #   procurement_ids += user.company.inward_invoices.with_type_non_po_invoice.pluck(:procurement_id)
    # end

    # self.procurements = user.company.procurements.with_ids(procurement_ids.uniq)

  end

  def success
    params[:procurements] = self.procurements
    Procurements::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements, :paginated_procurements, :count

    has_scope :filter_status_tags, type: :array
    has_scope :filter_po_number, :filter_invoice_number, :filter_doc_number
    has_scope :filter_sub_department, using: [:sub_department_name, :user_id], type: :hash
    has_scope :filter_vendor, using: [:vendor_name, :user_id], type: :hash
    has_scope :filter_user, using: [:user_details, :user_id], type: :hash
    has_scope :filter_payment_term, using: [:payment_term_name, :user_id], type: :hash
    has_scope :filter_category, using: [:category_name, :user_id], type: :hash
    has_scope :filter_po_status
    has_scope :filter_invoice_status
    has_scope :filter_submission_date, using: [:from, :to], type: :hash
    has_scope :filter_delivery_date
    has_scope :filter_received_date
    has_scope :filter_location, using: [:location_name, :user_id], type: :hash
    has_scope :filter_procurement_name
    has_scope :filter_procurement_type
    has_scope :filter_invoice_serial
    has_scope :filter_purchase_order_id, type: :array
    has_scope :filter_invoice_id, type: :array
    has_scope :filter_creation_date_from
    has_scope :filter_creation_date_to
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_cost_center_id
    has_scope :filter_location_id
    has_scope :filter_department_id
    has_scope :filter_sub_department_id

    def init
      self.procurements = params[:procurements]
      apply_filter

      self.procurements = self.procurements.order_by_controlling_level(user.id)
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_procurements = self.procurements.paginate(page: page, per_page: per_page).include_details
      self.count = self.procurements.count

    end

    def apply_filter
      if params[:search_type].present? && params[:search_query].present?
        set_scope
      end
      self.procurements = apply_scopes(self.procurements, params)

      if params[:filter_awaiting_approval].present?
        self.procurements = self.procurements.filter_awaiting_approval(user)
      end

    end

    def get_status_counts
      st_ids = StatusTag.all.pluck(:id)
      pr_ids = self.procurements.filter_procurement_type("purchase_order").pluck(:id)
      # ProcurementStatusTaggable.group(:status_tag_id).where(status_tag_id: st_ids).with_procurement_ids(pr_ids).size
      raw_count = ProcurementStatusTaggable.select('DISTINCT procurement_id, status_tag_id').with_procurement_ids(pr_ids).with_status_tag_ids(st_ids).group(:status_tag_id).count
      h = {}
      StatusTag.all.each {|ps| if raw_count.keys.include? ps.id then h[ps.name] = raw_count[ps.id] else h[ps.name] = 0 end}
      return h
    end

    def awaiting_action?(procurement)
    end
    
    def set_scope
      case params[:search_type]
        when 'invoice_number'
          params[:filter_invoice_number] = params[:search_query]
        when 'po_number'
          params[:filter_po_number] = params[:search_query]
        when 'doc_number'
          params[:filter_doc_number] = params[:search_query]
        when 'procurement_name'
          params[:filter_procurement_name] = params[:search_query]
        when 'sub_department_name'
          params[:filter_sub_department] = {
              sub_department_name: params[:search_query],
              user_id: user.id
          }
        when 'department_name'
          params[:filter_department] = {
              department_name: params[:search_query],
              user_id: user.id
          }
        when 'vendor_name'
          params[:filter_vendor] = {
              vendor_name: params[:search_query],
              user_id: user.id
          }
        when 'user_details'
          params[:filter_user] = {
              user_details: params[:search_query],
              user_id: user.id
          }
        when 'payment_term_name'
          params[:filter_payment_term] = {
              payment_term_name: params[:search_query],
              user_id: user.id
          }
        when 'category_name'
          params[:filter_category] = {
              category_name: params[:search_query],
              user_id: user.id
          }
        when 'invoice_id'
          params[:filter_invoice_id] = params[:search_query]
        else
          # do nothing
      end
    end

  end
end