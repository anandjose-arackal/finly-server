class Dashboard::VendorPayments::PurchaseRequests < Dashboard::VendorPayments::Base
  attr_accessor :purchase_requests

  def init
    self.purchase_requests = Procurements::PurchaseRequests::Index.(user, params).purchase_requests
  end

  def success
    params[:purchase_requests] = self.purchase_requests
    Dashboard::VendorPayments::PurchaseRequests::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::PurchaseRequests::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_requests, :counts

    has_scope :filter_status_id
    has_scope :filter_user_id

    # General Filters from frontend
    has_scope :filter_policy_id
    has_scope :filter_location_id
    has_scope :filter_department_id
    has_scope :filter_month
    has_scope :filter_year


    def init
      general_filter_params = {
        filter_policy_id: params[:filter_policy],
        filter_department_id: params[:filter_department],
        filter_month: params[:filter_month],
        filter_year: params[:filter_year],
        filter_location_id: params[:filter_location]
      }

      self.purchase_requests = params[:purchase_requests]
      self.purchase_requests = apply_scopes(self.purchase_requests, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: purchase_requests.count,
              filters: []
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_requests, {filter_status_id: PurchaseRequestStatus.id_for(:awaiting_approval)})&.count,
              filters: [
                {filter_po_status: PurchaseRequestStatus.id_for(:awaiting_approval)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_requests, {filter_status_id: PurchaseRequestStatus.id_for(:approved)})&.count,
              filters: [
                {filter_po_status: PurchaseRequestStatus.id_for(:approved)}
              ]
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.is_purchase_request_initiator? || user.vp_admin_or_auditor?
        personal_data = {
          type: 'personal',
          data: [
            {
              title: "Total",
              count: apply_scopes(purchase_requests, {filter_user_id: user.id})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(purchase_requests, {filter_user_id: user.id, filter_status_id: PurchaseRequestStatus.id_for(:awaiting_approval)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {filter_po_status: PurchaseRequestStatus.id_for(:awaiting_approval)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(purchase_requests, {filter_user_id: user.id, filter_status_id: PurchaseRequestStatus.id_for(:approved)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {filter_po_status: PurchaseRequestStatus.id_for(:approved)}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end

      # if user.is_purchase_request_reviewer?
      #   reviewer_data = {
      #     type: "reviewer",
      #     data: [
      #       {
      #         title: "Awaiting Approval",
      #         count: PurchaseRequest.awaiting_action_items(user)&.count,
      #         filters: [{filter_awaiting_approval: true}]
      #       }
      #     ]
      #   }
      #   self.counts.push(reviewer_data)
      # end
    end
  end
end