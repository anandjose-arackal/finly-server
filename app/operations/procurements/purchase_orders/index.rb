class Procurements::PurchaseOrders::Index < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_orders, :policies

  def init

  end

  def validate

  end

  def process
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [PurchaseOrderStatus.id_for(:open)]
      self.purchase_orders = ::PurchaseOrder.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}).not_open.or(user.purchase_orders)
      return
    end

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

    has_scope :filter_awaiting_approval
    has_scope :filter_user
    has_scope :filter_vendor_id

    # has_scope :filter_status_tags, type: :array
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
      self.purchase_orders = params[:purchase_orders]
      self.purchase_orders = apply_scopes(self.purchase_orders, params)

      page = params[:page] || 1
      per_page = params[:per_page] || 30
    
      self.paginated_purchase_orders = self.purchase_orders.paginate(page: page, per_page: per_page).includes_for_index
    end
  end
end