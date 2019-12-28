class Procurements::PurchaseOrders::Index < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :policies

  def init

  end

  def validate

  end

  def process
    # if user.vendor_payments_admin? && params[:team_po] == false
    if user.vendor_payments_admin? or RequestStore.store[:vendor_manager]
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      self.purchase_orders = ::PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.purchase_orders)
      return
    end

    # if user.vendor_payments_reviewer? && params[:team_po]
    # if user.vendor_payments_reviewer?
    #   self.purchase_orders = ::PurchaseOrder.role_based_reviewer_associated_items(user, UserRole.id_for(:purchase_order_reviewer))
    #   return
    # end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.purchase_orders = ::PurchaseOrder.associated_items(user, ::PurchaseOrder.roles) || PurchaseOrder.none
    else
      self.purchase_orders = user.purchase_orders
    end
  end

  def success
    params[:purchase_orders] = self.purchase_orders
    Procurements::PurchaseOrders::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_orders, :paginated_purchase_orders

    has_scope :filter_ids, type: :array
    has_scope :filter_user
    has_scope :filter_po_number
    has_scope :filter_status
    has_scope :filter_delivery_date
    has_scope :filter_procurement_name
    has_scope :filter_creation_date_from
    has_scope :filter_creation_date_to
    has_scope :filter_submission_date_from
    has_scope :filter_submission_date_to
    has_scope :filter_month
    has_scope :filter_year

    has_scope :filter_user_id
    has_scope :filter_policy_id
    has_scope :filter_vendor_id
    has_scope :filter_cost_center_id
    has_scope :filter_location_id
    has_scope :filter_department_id
    has_scope :filter_pr_number

    has_scope :filter_awaiting_approval
    has_scope :show_only_po_which_have_advances
    has_scope :show_only_po_which_are_forwarded
    has_scope :filter_all_advances, type: :boolean
    has_scope :filter_po_advance_status
    has_scope :po_advances_date, using: [:from, :to], type: :hash
    has_scope :due_date, using: [:from, :to], type: :hash
    has_scope :filter_po_approver_id
    has_scope :filter_custom_text_selection, type: :array
    has_scope :filter_custom_drop_down_selection, type: :array

    # Sorting
    has_scope :sort_po_number
    has_scope :sort_po_name
    # has_scope :sort_amount

    has_scope :filter_delivery_location

    def init
      self.purchase_orders = params[:purchase_orders]
      self.purchase_orders = apply_scopes(self.purchase_orders, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 30
    
      self.paginated_purchase_orders = self.purchase_orders.order(created_at: :desc).paginate(page: page, per_page: per_page).includes_for_index
    end

    def get_counts
      result = {
        all: 0,
        draft: 0,
        processing: 0,
        approved: 0,
        awaiting_approval: 0,
        sent_to_vendor: 0,
        vendor_confirmed: 0,
        closed: 0,
        revised: 0,
        voided: 0
      }

      po_status_ids = PurchaseOrder.status_ids(:open, :retracted, :processing, :approved, :rejected, :auto_approved, :sent_to_vendor, :closed, :voided, :po_revised, :vendor_confirmed)
      po_status_counts = self.purchase_orders.where(purchase_order_status_id: po_status_ids)&.group(:purchase_order_status_id)&.count

      result[:all] = self.purchase_orders.count

      result[:awaiting_approval] = self.purchase_orders.awaiting_action_items(user).count

      PurchaseOrderStatus.all.map do |status|
        case status.id
        when PurchaseOrderStatus.id_for(:open), PurchaseOrderStatus.id_for(:retracted), PurchaseOrderStatus.id_for(:rejected)
          result[:draft] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:processing)
          result[:processing] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:approved), PurchaseOrderStatus.id_for(:auto_approved) 
          result[:approved] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:sent_to_vendor)
          result[:sent_to_vendor] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:closed)
          result[:closed] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:voided)
          result[:voided] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:po_revised)
          result[:revised] += (po_status_counts[status.id] || 0)
        when PurchaseOrderStatus.id_for(:vendor_confirmed)
          result[:vendor_confirmed] += (po_status_counts[status.id] || 0)
        end
      end

      result[:awaiting_approval] = self.purchase_orders.awaiting_action_items(user).count
      result
    end
  end
end
