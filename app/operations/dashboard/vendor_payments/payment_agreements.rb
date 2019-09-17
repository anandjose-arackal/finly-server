class Dashboard::VendorPayments::PaymentAgreements < Dashboard::VendorPayments::Base

  attr_accessor :payment_agreements

  def init
    params[:filter_by_date_range] = {}
    params[:filter_by_date_range][:from] = params[:filter_date_from] if params[:filter_date_from].present?
    params[:filter_by_date_range][:to] = params[:filter_date_to] if params[:filter_date_to].present?
    self.payment_agreements = ::PaymentAgreements::Index.(user, params).payment_agreements
  end

  def success
    params[:payment_agreements] = self.payment_agreements
    Dashboard::VendorPayments::PaymentAgreements::DashboardPresenter.new(user, params, messages)
  end

  class Dashboard::VendorPayments::PaymentAgreements::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_agreements, :counts

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

      self.payment_agreements = params[:payment_agreements]
      self.payment_agreements = apply_scopes(self.payment_agreements, general_filter_params)
      self.counts = []

      if user.vendor_payments_admin?
        admin_data = {
          type: 'admin',
          data: [
            {
              title: "Total",
              count: payment_agreements.count,
              filters: []
            },
            {
              title: "Processing",
              count: apply_scopes(payment_agreements, {filter_status_id: PaymentAgreementStatus.id_for(:awaiting_approval)})&.count,
              filters: [
                {filter_by_status_id: PaymentAgreementStatus.id_for(:awaiting_approval)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_agreements, {filter_status_id: PaymentAgreementStatus.id_for(:approved)})&.count,
              filters: [
                {filter_by_status_id: PaymentAgreementStatus.id_for(:approved)}
              ]
            }
          ]
        }

        self.counts.push(admin_data)
      end

      if user.is_payment_agreement_initiator? || user.vp_admin_or_auditor?
        personal_data = {
          type: 'personal',
          data: [
            {
              title: "Total",
              count: apply_scopes(payment_agreements, {filter_user_id: user.id})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {search_by_email: user.email}
              ]
            },
            {
              title: "Processing",
              count: apply_scopes(payment_agreements, {filter_user_id: user.id, filter_status_id: PaymentAgreementStatus.id_for(:awaiting_approval)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {search_by_email: user.email},
                {filter_by_status_id: PaymentAgreementStatus.id_for(:awaiting_approval)}
              ]
            },
            {
              title: "Approved",
              count: apply_scopes(payment_agreements, {filter_user_id: user.id, filter_status_id: PaymentAgreementStatus.id_for(:approved)})&.count,
              filters: [
                {search_type: 'user_details'},
                {search_query: user.email},
                {search_by_email: user.email},
                {filter_by_status_id: PaymentAgreementStatus.id_for(:approved)}
              ]
            }
          ]
        }
        self.counts.push(personal_data)
      end


      self.counts.each do |count_object|
        count_object[:data].each do |data|
           if params[:filter_by_date_range].present? && params[:filter_by_date_range][:from].present?
             filter_date = {'filter_by_date_range[from]': params[:filter_by_date_range][:from]}
             data[:filters].push(filter_date)
           end

          if params[:filter_by_date_range].present? && params[:filter_by_date_range][:to].present?
             filter_date = {'filter_by_date_range[to]': params[:filter_by_date_range][:to]}
             data[:filters].push(filter_date)
           end
        end
      end

    end

  end
end