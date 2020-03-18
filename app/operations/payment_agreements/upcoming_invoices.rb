class PaymentAgreements::UpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies

  def init
    id = params[:id] || params[:payment_agreement_id]
    self.payment_agreement = user.company.payment_agreements.find_by_id id
  end

  def validate
    if payment_agreement.blank?
      add_message :error, 'Agreement not found'
      return
    end

    unless payment_agreement.approved? || payment_agreement.auto_approved?
      add_message :error, 'Payment agreement should be approved for raising invoices'
    end

  end

  def process 
    unless payment_agreement.status.terminated?
      one_time_gi_invoices = payment_agreement.general_invoices.where(billing_type_id: BillingType.id_for(:one_time))
      fixed_periodic_gi_invoices = payment_agreement.fixed_periodic_general_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where(fixed_periodic_template: true) rescue GeneralInvoice.none

      self.general_invoices = one_time_gi_invoices.or(fixed_periodic_gi_invoices)


      one_time_ri_invoices = payment_agreement.rental_invoices.where(billing_type_id: BillingType.id_for(:one_time))

      fixed_periodic_ri_invoices = payment_agreement.fixed_periodic_rental_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where(fixed_periodic_template: true) rescue RentalInvoice.none

      self.rental_invoices = one_time_ri_invoices.or(fixed_periodic_ri_invoices)
    end

    initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
    self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
  end

  def success
    params[:beneficiary_payments] = self.beneficiary_payments
    params[:security_deposits] = self.security_deposits
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    params[:policies] = self.policies
    PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::UpcomingInvoices::UpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies,
                  :paginated_general_invoices, :paginated_rental_invoices

    has_scope :filter_upcoming_invoice_date, using: [:from, :to], type: :hash

    def init
      page = params[:page] || 1
      per_page = params[:per_page] || 30
      
      self.beneficiary_payments = params[:beneficiary_payments]
      self.security_deposits = params[:security_deposits]
      self.general_invoices = params[:general_invoices]
      if self.general_invoices.present?
        self.general_invoices = apply_scopes(general_invoices, params)
      end

      self.paginated_general_invoices = self.general_invoices.paginate(page: page, per_page: per_page) rescue ::GeneralInvoice.none

      self.rental_invoices = params[:rental_invoices]
      if self.rental_invoices.present?
        self.rental_invoices = apply_scopes(rental_invoices, params)
      end
      self.paginated_rental_invoices = self.rental_invoices.paginate(page: page, per_page: per_page) rescue ::RentalInvoice.none

      self.policies = params[:policies]
    end
  end

end