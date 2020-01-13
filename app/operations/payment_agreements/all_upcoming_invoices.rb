class PaymentAgreements::AllUpcomingInvoices < PaymentAgreements::Base
  attr_accessor :invoices, :payment_agreement, :beneficiary_payments, :security_deposits, :general_invoices, :rental_invoices, :policies

  def init
  end

  def validate

  end

  def process 
    # self.general_invoices = user.company.general_invoices.where.not(billing_type_id: BillingType.id_for(:variable_periodic)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none

    one_time_gi_invoices = user.company.general_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue GeneralInvoice.none

    fixed_periodic_gi_invoices = user.company.fixed_periodic_general_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue GeneralInvoice.none

    self.general_invoices = one_time_gi_invoices.or(fixed_periodic_gi_invoices)


    one_time_ri_invoices = user.company.rental_invoices.where(billing_type_id: BillingType.id_for(:one_time)).where("start_date <= ? AND end_date >= ? AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue RentalInvoice.none

    fixed_periodic_ri_invoices = user.company.fixed_periodic_rental_invoices.where(billing_type_id: BillingType.id_for(:fixed_periodic), is_payment_agreement_upcoming_invoice: true).where("payment_agreement_upcoming_date <= ?", Date.today).where(fixed_periodic_template: true) rescue RentalInvoice.none

    self.rental_invoices = one_time_ri_invoices.or(fixed_periodic_ri_invoices)

    # self.rental_invoices = user.company.rental_invoices.where.not(billing_type_id: BillingType.id_for(:variable_periodic)).where("start_date <= ? AND end_date >= ?  AND payment_agreement_upcoming_date <= ?", Date.today, Date.today, Date.today).where(is_payment_agreement_upcoming_invoice: true) rescue Invoice.none

    initiating_user = self.payment_agreement.present? ? payment_agreement.creator : user
    self.policies = Policy::VendorPayments::Index.(initiating_user, params).policies
  end

  def success
    params[:general_invoices] = self.general_invoices
    params[:rental_invoices] = self.rental_invoices
    params[:policies] = self.policies
    PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter.new(user, params, messages)
  end

  class PaymentAgreements::AllUpcomingInvoices::AllUpcomingInvoicesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoices, :general_invoices, :rental_invoices, :policies

    has_scope :filter_policy_id
    has_scope :filter_vendor_id
    has_scope :filter_due_date
    has_scope :filter_creation_date
    has_scope :filter_from_date
    has_scope :filter_to_date

    def init
      self.general_invoices = params[:general_invoices]
      self.general_invoices = apply_scopes(general_invoices, params)
      self.rental_invoices = params[:rental_invoices]
      self.rental_invoices = apply_scopes(rental_invoices, params)
      if params[:agreement_item_type].present?
        filter_agreement_item_type
      end
      self.policies = params[:policies]
    end
  end

  def filter_agreement_item_type
    case params[:filter_agreement_item_type]
    when 'general_invoice'
      self.rental_invoice = nil
    when 'rental_invoice'
      self.general_invoice = nil
    end
  end

end