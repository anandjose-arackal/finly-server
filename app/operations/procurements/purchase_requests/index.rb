class Procurements::PurchaseRequests::Index < Procurements::PurchaseRequests::Base
  attr_accessor :purchase_requests, :policies
  def init

  end

  def validate

  end

  def process
    if user.vp_admin_or_auditor?
      admin_restricted_status_ids = [PurchaseRequestStatus.id_for(:draft)]
      # self.purchase_requests = user.company.purchase_requests.with_ids(::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids}) )
      self.purchase_requests = ::PurchaseRequest.role_based_admin_associated_items(user, UserRole.id_for(:admin), {admin_restricted_status_ids: admin_restricted_status_ids})&.not_draft
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
    Procurements::PurchaseRequests::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseRequests::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests, :paginated_purchase_requests, :count

    has_scope :filter_by_status_id
    has_scope :search_by_email
    has_scope :filter_by_date_range, using: [:from, :to], type: :hash
    has_scope :filter_by_request_id
    has_scope :filter_by_title
    has_scope :filter_by_department_id
    has_scope :filter_by_location_id

    def init
      self.purchase_requests = params[:purchase_requests]
      self.purchase_requests = apply_scopes(purchase_requests, params) rescue ::PurchaseRequest.none
      self.paginated_purchase_requests = purchase_requests.paginate(page: params[:page], per_page: 30) rescue ::PurchaseRequest.none
      self.count = purchase_requests&.count
    end

  end
end