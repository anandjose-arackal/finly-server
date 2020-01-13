class Procurements::PurchaseRequests::Index < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests, :policies, :filter_ids
  def init
    self.filter_ids = params[:filter_ids]
    if self.filter_ids.present?
      self.filter_ids = filter_ids[0].split(",").reject { |id| id.empty? } rescue []
    end
  end

  def validate

  end

  def process
    if user.vendor_payments_admin?
      admin_restricted_status_ids = [PurchaseRequestStatus.id_for(:draft)]
      # self.purchase_requests = user.company.purchase_requests.with_ids(::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}) )
      self.purchase_requests = ::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})
      self.purchase_requests = user.purchase_requests.or(purchase_requests)
      return
    end

    unless user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.purchase_requests = ::PurchaseRequest.associated_items(user, ::PurchaseRequest.roles) || PurchaseRequest.none
    else
      self.purchase_requests = user.purchase_requests
    end
  end

  def success
    params[:purchase_requests] = self.purchase_requests
    params[:filter_ids] = self.filter_ids
    Procurements::PurchaseRequests::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests, :paginated_purchase_requests, :count, :filter_ids

    has_scope :filter_by_status_id
    has_scope :search_by_email
    has_scope :filter_by_date_range, using: [:from, :to], type: :hash
    has_scope :filter_by_request_id
    has_scope :filter_by_title
    has_scope :filter_by_department_id
    has_scope :filter_by_location_id
    has_scope :filter_awaiting_approval
    has_scope :filter_policy_id
    has_scope :filter_pr_creator_id
    has_scope :filter_pr_approver_id

    has_scope :sort_order_number
    has_scope :sort_description
    has_scope :sort_date
    has_scope :filter_custom_text_selection, type: :array
    has_scope :filter_custom_drop_down_selection, type: :array
    # has_scope :sort_amount

    def init
      self.purchase_requests = params[:purchase_requests]
      self.filter_ids = params[:filter_ids]
      self.purchase_requests = apply_scopes(purchase_requests, params) rescue ::PurchaseRequest.none
      self.paginated_purchase_requests = purchase_requests.order(created_at: :desc).paginate(page: params[:page], per_page: 30) rescue ::PurchaseRequest.none
      # If certain PR's are selected in export, override purchase_requests with the filtered requests
      if self.filter_ids.present?
        self.purchase_requests = user.company.purchase_requests.where(id: self.filter_ids)
      end 
      self.count = purchase_requests&.count
    end

  end
end