class Dashboard::VendorPayments::Vendors < Dashboard::VendorPayments::Base
  attr_accessor :vendors

  def init
    params[:non_deleted] = true
    params[:authorized] = true
    # Set date filters
    params[:filter_creation_date] = {} if params[:filter_date_from].present? || params[:filter_date_to].present?
    params[:filter_creation_date][:from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date][:to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.vendors = ::Vendors::Index.(user, params).vendors
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

      # Set Date Filters in Filters
      # Done because the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
           if params[:filter_creation_date].present? && params[:filter_creation_date][:from].present?
             filter_date = {'filter_creation_date[from]': params[:filter_creation_date][:from]}
             data[:filters].push(filter_date)
           end

          if params[:filter_creation_date].present? && params[:filter_creation_date][:to].present?
             filter_date = {'filter_creation_date[to]': params[:filter_creation_date][:to]}
             data[:filters].push(filter_date)
           end
        end
      end
    end
  end
end