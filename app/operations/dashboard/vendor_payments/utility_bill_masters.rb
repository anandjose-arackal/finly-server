class Dashboard::VendorPayments::UtilityBillMasters < Dashboard::VendorPayments::Base
  attr_accessor :utility_bill_masters

  def init
    # Set date filters
    params[:filter_creation_date] = {} if params[:filter_date_from].present? || params[:filter_date_to].present?
    params[:filter_creation_date][:from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_creation_date][:to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.utility_bill_masters = Docs::UtilityBills::Subscriptions::Ops::Index.(params: params, current_user: user)['result']&.dig('subscriptions')
  end

  def success
    params[:utility_bill_masters] = self.utility_bill_masters
    Dashboard::VendorPayments::UtilityBillMasters::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::UtilityBillMasters::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :utility_bill_masters, :counts

    has_scope :filter_status
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
          filter_location_id: params[:filter_location],
          filter_cost_center_id: params[:filter_cost_center]
      }

      self.utility_bill_masters = params[:utility_bill_masters]
      self.utility_bill_masters = apply_scopes(self.utility_bill_masters, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
            type: 'admin',
            data: [
                {
                    title: "Total",
                    count: utility_bill_masters.count,
                    filters: []
                },
                {
                    title: "Processing",
                    count: utility_bill_masters.filter_status('processing')&.count,
                    filters: [
                        {filter_status: 'processing'}
                    ]
                },
                {
                    title: "Approved",
                    count: utility_bill_masters.filter_status('approved')&.count,
                    filters: [
                        {filter_status: 'approved'}
                    ]
                },
                {
                    title: "Reactivated",
                    count: utility_bill_masters.filter_status('reactivated')&.count,
                    filters: [
                        {filter_status: 'reactivated'}
                    ]
                },
                {
                    title: "Deactivated",
                    count: utility_bill_masters.filter_status('deactivated')&.count,
                    filters: [
                        {filter_status: 'deactivated'}
                    ]
                }
            ]
        }

        self.counts.push(admin_data)
      end

      if user.is_utility_bill_master_initiator? || user.vp_admin_or_auditor?
        personal_data = {
            type: 'personal',
            data: [
                {
                    title: "Total",
                    count: utility_bill_masters.filter_user_id(user.id)&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name}
                    ]
                },
                {
                    title: "Processing",
                    count: utility_bill_masters.filter_user_id(user.id).filter_status('processing')&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name},
                        {filter_status: 'processing'}
                    ]
                },
                {
                    title: "Approved",
                    count: utility_bill_masters.filter_user_id(user.id).filter_status('approved')&.count,
                    filters: [
                        {filter_user_id: user.id},
                        {filter_user_name: user.name},
                        {filter_status: 'approved'}
                    ]
                },
                {
                    title: "Rejected",
                    count: utility_bill_masters.filter_user_id(user.id).filter_status('rejected')&.count,
                    filters: [
                        {filter_status: 'rejected'}
                    ]
                },
                {
                    title: "Retracted",
                    count: utility_bill_masters.filter_user_id(user.id).filter_status('retracted')&.count,
                    filters: [
                        {filter_status: 'retracted'}
                    ]
                }
            ]
        }
        self.counts.push(personal_data)
      end


      # Set Date Filters in Filters
      # Done becauase the filters in index page and the filters passed in dashboard for date filters are different
      self.counts.each do |count_object|
        count_object[:data].each do |data|
          if params[:filter_creation_date_from].present?
            date_filter_from = {filter_creation_date_from: params[:filter_creation_date_from]}
            data[:filters].push(date_filter_from)
          end

          if params[:filter_creation_date_to].present?
            date_filter_to = {filter_creation_date_to: params[:filter_creation_date_to]}
            data[:filters].push(date_filter_to)
          end
        end
      end
    end
  end
end