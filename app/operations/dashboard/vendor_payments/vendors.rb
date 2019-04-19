class Dashboard::VendorPayments::Vendors < Dashboard::VendorPayments::Base
  attr_accessor :vendors

  def init
    self.vendors = Vendors::Index.(user, params).vendors
  end

  def success
    params[:vendors] = self.vendors
    Dashboard::VendorPayments::Vendors::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::Vendors::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :vendors, :counts

    has_scope :filter_status_id
    has_scope :filter_user_id

    # General Filters from frontend
    has_scope :filter_policy_id
    has_scope :filter_department_id
    has_scope :filter_sub_department_id
    has_scope :filter_month
    has_scope :filter_year

    def init
      general_filter_params = {
        filter_policy_id: params[:filter_policy],
        # filter_department_id: params[:filter_department],
        # filter_sub_department_id: params[:filter_sub_department],
        filter_month: params[:filter_month],
        filter_year: params[:filter_year]
      }

      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, general_filter_params)
      self.counts = []

      if user.is_vendor_reviewer?
        reviewer_data = {
          type: "reviewer",
          title: "Vendors",
          data: [
            {
              title: "Awaiting Approval",
              count: YesBankVendor.awaiting_action_items(user).count,
              filters: [
                {filter_status_id: 'awaiting_approval'}
              ]
            }
          ]
        }
        self.counts.push(reviewer_data)
      end
    end
  end
end