class Procurements::Grn::Pending::Index < Procurements::Base

  attr_accessor :procurements, :filter_procurement_type, :filter_awaiting_action

  def pre_validate
    unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
      add_message :error, "Receipt note is not enabled for your company. Please contact your admin or Finly Customer Support."
      return
    end
  end
  
  def init
    self.filter_procurement_type = params[:filter_procurement_type]
    self.filter_awaiting_action = !!StringUtils.to_bool(params[:filter_awaiting_action])
  end

  def validate
    unless user.vp_admin_or_auditor? || user.is_goods_receiver?
      add_message :error, 'Role not found'
      return
    end

    if (params[:filter_status_tags].present? and (filter_procurement_type == 'purchase_order')) || (params[:document_type] == 'grn_count')
      return
    end
    add_message :error, 'No documents found at this state'
  end

  def process
    if user.vendor_payments_admin? || user.is_goods_receiver?
      if (params[:filter_status_tags].present? and (filter_procurement_type == 'purchase_order')) || (params[:document_type] == 'grn_count')
        # received_pending_ids = [StatusTag.id_for(:shipment_received), StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]
        # Get all policies where user has goods receiver role
        received_pending_ids = [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]
        
        if user.vendor_payments_admin? && !filter_awaiting_action
          pr_ids = user.company.procurements.pluck(:id)
        else
          policy_ids = user.company.policies.joins(:policy_user_roles).where('policy_user_roles.user_role_id = ? AND user_id = ?', UserRole.id_for(:goods_receiver), user.id).pluck(:id).uniq rescue []
          pr_ids = user.company.procurements.joins(:purchase_order).where('purchase_orders.policy_id IN (?)', policy_ids).pluck(:id)
        end
        st_ids = StatusTag.where(id: received_pending_ids).pluck(:id)
        proc_ids = ProcurementStatusTaggable.select('DISTINCT procurement_id, status_tag_id').with_procurement_ids(pr_ids).with_status_tag_ids(st_ids).pluck(:procurement_id)
        self.procurements = Procurement.where(id: proc_ids).joins(:purchase_order).where.not('purchase_orders.purchase_order_status_id IN (?)', PurchaseOrderStatus.ids_for([:closed, :voided])) rescue Procurement.none
      end
    end
  end

  def success
    params[:procurements] = self.procurements
    Procurements::Grn::Pending::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Grn::Pending::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
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
    has_scope :filter_submission_date
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
    has_scope :filter_grn_due_today
    has_scope :filter_grn_overdue
    has_scope :filter_policy_id
    has_scope :filter_pr_number
    has_scope :filter_pr_creator_id

    def init
      self.procurements = params[:procurements]
      apply_filter
      self.procurements = procurements.order_by_controlling_level(user.id).order_by_expected_delivery_date(user.id)
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_procurements = self.procurements.paginate(page: page, per_page: per_page).grn_include_details
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
      # received_pending_ids = [StatusTag.id_for(:shipment_received), StatusTag.id_for(:receiving_shipment)]
      received_pending_ids = [StatusTag.id_for(:receiving_shipment)]
      st_ids = StatusTag.where(id: received_pending_ids).pluck(:id)
      pr_ids = self.procurements.pluck(:id)
      # ProcurementStatusTaggable.group(:status_tag_id).where(status_tag_id: st_ids).with_procurement_ids(pr_ids).size
      raw_count = ProcurementStatusTaggable.select('DISTINCT procurement_id, status_tag_id').with_procurement_ids(pr_ids).with_status_tag_ids(st_ids).group(:status_tag_id).count
      h = {}
      
      StatusTag.where(id: received_pending_ids).each {|ps| if raw_count.keys.include? ps.id then h[ps.name] = raw_count[ps.id] else h[ps.name] = 0 end}
    
      h["receiving_shipment"] = self.count 
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
        when 'pr_number'
          params[:filter_pr_number] = params[:search_query]
        else
          # do nothing
      end
    end

  end

end