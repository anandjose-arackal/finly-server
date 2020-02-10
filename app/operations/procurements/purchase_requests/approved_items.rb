class Procurements::PurchaseRequests::ApprovedItems < Procurements::PurchaseRequests::Base

  attr_accessor :approved_purchase_request_items, :policies
  def init

  end

  def validate

  end

  def process

  end

  def success
    # params[:purchase_requests] = self.purchase_requests
    Procurements::PurchaseRequests::ApprovedItems::ApprovedItemsPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::ApprovedItems::ApprovedItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :approved_purchase_request_items, :paginated_items, :count, :rate_contract_number

    has_scope :date
    has_scope :order_number
    has_scope :vendor_id
    has_scope :item_id
    has_scope :location_id
    has_scope :search_delivery_location
    has_scope :search_preferred_vendor
    has_scope :search_order_number
    has_scope :search_item_name
    has_scope :role_based_filter

    def init
      # Get policies in which user has purchase order initiator or inventory manager role
      if user.vendor_payments_admin?
        approved_item_ids = user.company.purchase_requests.joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)]).pluck('purchase_request_items.id')
        self.approved_purchase_request_items = PurchaseRequestItem.with_ids(approved_item_ids)
      else
        # role_based_policy_ids = user.company.policies.joins(:policy_user_roles).with_application('vp').where('policy_user_roles.user_role_id IN (?)', [UserRole.id_for(:purchase_order_initiator), UserRole.id_for(:inventory_manager)]).pluck(:id).uniq rescue []
        # approved_item_ids = user.company.purchase_requests.where(policy_id: role_based_policy_ids).joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)]).pluck('purchase_request_items.id')
        purchase_requests = user.company.purchase_requests.role_based_filter(true)
        approved_item_ids = purchase_requests.joins(:purchase_request_items).where('purchase_request_items.status_id IN (?)', [PurchaseRequestItemStatus.id_for(:approved), PurchaseRequestItemStatus.id_for(:auto_approved)]).pluck('purchase_request_items.id')
        self.approved_purchase_request_items = PurchaseRequestItem.with_ids(approved_item_ids)
      end
      apply_search
      self.approved_purchase_request_items = apply_scopes(self.approved_purchase_request_items, params)
      self.paginated_items = self.approved_purchase_request_items.paginate(page: params[:page], per_page: params[:per_page]) rescue nil
      self.count = self.approved_purchase_request_items.count
    end

    def apply_search
      if params[:search_type].present? && params[:search_query].present?
        set_scope
      end
    end

    def set_scope
      case params[:search_type]
        when 'item_name'
          params[:search_item_name] = params[:search_query]
        when 'order_id'
          params[:search_order_number] = params[:search_query]
        when 'preferred_vendor'
          params[:search_preferred_vendor]  = params[:search_query]
        when 'delivery_location'
          params[:search_delivery_location] = params[:search_query]
      end
    end

  end

end